# LuxeCart – Modern Ruby on Rails E‑Commerce Platform

LuxeCart is a full‑stack e‑commerce web application built with Ruby on Rails. It aims to provide a realistic online store experience with modern UI, category‑based browsing, a cart and checkout flow, Stripe integration (for payments), and an admin‑friendly architecture that can be extended into a production‑ready shop.

## What this system is

At a high level, LuxeCart is:

- A **multi‑category online store** (furniture/home decor in your seed data)  
- With a **session‑based cart** on the storefront side (what customers see)
- And a **database‑backed cart/order system** for checkout and persistence
- Using **Devise authentication** for users
- And **Stripe** for payment intent creation and processing
- Wrapped in a **modern, responsive UI** built mostly in ERB with Tailwind‑style utility classes

The project is structured as a typical Rails monolith: one application handles the public storefront, user accounts, cart/checkout logic, and orders.

---

## Core features (theory overview)

### 1. Product catalog and categories

- `Product` model: represents items that can be browsed and purchased.
  - Fields like `name`, `price`, `sku`, `description`, `image_url` / `image` etc.
- `Category` model: organizes products into top‑level and child categories.
  - Dedicated views for categories: `men`, `women`, `children`, and a generic `category_shop`.
  - Category pages use curated **placeholder hero images** plus product images when present.
- Product pages:
  - `products#index` and `products#show` render product cards and details.
  - Each product card includes:
    - Image (from `image_url` / `image` or placeholders)
    - Name, price
    - “Add to cart” button using AJAX
    - Link to view details

Conceptually: this layer is your **catalog system** – the data and UI that describe what can be bought.

---

### 2. Cart system (storefront)

The visible cart that your user interacts with is primarily **session‑based**:

- `session[:cart]` holds a simple hash of `product_id => quantity`.
- `CartsController#show`:
  - Reads `session[:cart]`
  - Loads the corresponding `Product` records
  - Builds `@items = [{ product: Product|nil, product_id: Integer, quantity: Integer }, …]`.
- `app/views/carts/show.html.erb`:
  - Renders a modern cart table:
    - Product image (via `product_image_src` helper)
    - Name, SKU
    - Price, quantity controls (+/–), subtotal per line
    - Total at the bottom
  - Provides controls:
    - Increase quantity
    - Decrease quantity (down to zero = remove)
    - Remove item entirely
  - Uses client‑side JavaScript (fetch + JSON) to:
    - Call `/cart/add_item`, `/cart/update_item/:id`, `/cart/remove_item/:id`
    - Update totals and the header cart badge without full page reload.

Conceptually: this is the **“live cart UI”** that the customer sees, entirely driven from the session hash and AJAX endpoints.

---

### 3. Add‑to‑cart & session management

- `CartItemsController#create`:
  - Finds the product by `params[:product_id]`.
  - Ensures `session[:cart]` is a hash.
  - Increments the quantity for that product id.
  - Responds with JSON `{ cart: session[:cart], cart_count: total_quantity }` for AJAX callers.
- Category/product views use a `.add-to-cart-ajax` button:
  - Attached JS sends a `POST` to `/cart/add_item`.
  - On success, updates the header cart badge.

Conceptually: this is the **cart mutation API** used by all front‑end buttons (still in Rails/ERB, but acting like a mini SPA for cart operations).

---

### 4. Checkout and orders

The checkout flow is implemented in two related controllers:

- **OrdersController** (for `/orders/new`, `/orders/create`, `/orders/:id/success`)
- **CheckoutController** (for `/checkout/new`, `/checkout/create` in the more advanced flow)

Both now share the same concept: they **build orders from `session[:cart]`**, not from a separate DB cart.

The core responsibilities:

1. **Ensure cart is not empty**
   - `before_action :load_session_cart`
   - `before_action :ensure_cart_not_empty`
   - If the session cart hash is blank, redirect back to `/cart` with “Your cart is empty.”

2. **Order creation from the session cart**
   - For each `{product_id_str, qty}` in `session[:cart]`:
     - Load the `Product`
     - Determine unit price (`product.price`)
     - Compute line total `unit_price * quantity`
     - Build `order_items` with a snapshot of:
       - `product_id`
       - `quantity`
       - `unit_price`
       - `total_price`
       - `product_name`
       - `product_sku`
   - Compute server‑side:
     - `subtotal` (sum of line totals)
     - `shipping_cost` (currently static, e.g. 9.99 or 0.0 depending on controller)
     - `tax`
     - `total_price`
   - Persist `Order` + `OrderItems`
   - Clear `session[:cart]` upon successful order (so `/cart` empties).

3. **Checkout UI**
   - `app/views/checkout/new.html.erb`:
     - Two‑column layout:
       - Left: address selection / shipping form.
       - Right: order summary (partial `_order_summary.html.erb`).
   - `_order_summary.html.erb`:
     - Shows each line item (name, quantity, per‑item price, line total).
     - Computes and presents:
       - Items subtotal
       - Shipping & handling
       - Before tax
       - Tax collected
       - Order total
     - Styled as a premium summary card.

Conceptually: this layer turns the **ephemeral session cart** into a **persistent order** and handles the last steps before payment.

---

### 5. Payments (Stripe integration)

- The payment logic is primarily in `CheckoutController#process_payment`:
  - For `payment_method == 'stripe'`:
    - Creates a `Stripe::PaymentIntent` with:
      - `amount` = `order.total_price` in cents
      - `currency` = `'usd'`
      - `metadata` = `{ order_id: order.id }`
    - Stores `stripe_payment_intent_id` on the order.
    - Marks payment as successful or failed based on the Stripe response.
  - For other payment methods:
    - Currently treated as successful (placeholder for COD or other gateways).

Conceptually: this is the **payment gateway abstraction**; today it focuses on Stripe but is designed so other methods can be added.

---

### 6. User accounts & addresses

- Uses **Devise** (or similar) for `User` authentication:
  - Users must be logged in to access checkout and create orders.
- There is an `Address` model (from the `addresses` controllers/views in the repo):
  - Users can manage multiple addresses.
  - Checkout lets the user select an existing address or add a new one.
  - A default address can be flagged and is preferred in the flow.

Conceptually: this is your **account management & address book** layer, enabling realistic shipping flows.

---

### 7. Admin / internal structure (foundation)

Although much of the explicit “admin UI” isn’t wired in the views you’ve shown, the structure suggests:

- A reusable `current_cart` method in `ApplicationController`:
  - DB‑backed `Cart` model used historically or by admin flows.
- Models for:
  - `Cart`, `CartItem`
  - `Order`, `OrderItem`
  - `Category`, `Product`, maybe `Brand`
- This makes it possible to:
  - Build a separate admin dashboard for managing products, categories, orders.
  - Run reports and analytics over carts and orders.

Conceptually: this is the **domain model foundation** that can back both storefront and admin experiences.

---

## Architecture summary

- **Backend:** Ruby on Rails 7.x
- **Views:** ERB templates with Tailwind‑style utility classes (custom CSS + some Tailwind‑like naming)
- **State:**
  - Customer cart state: `session[:cart]` (hash of product_id → quantity)
  - Persistent domain state: `Cart`, `Order`, `OrderItem`, `Address`, `User`, `Product`, `Category`, …
- **AJAX / JS:** Vanilla JS using `fetch` for cart operations (`/cart/add_item`, `/cart/update_item`, `/cart/remove_item`).
- **Authentication:** Devise (or similar) for `User`.
- **Payments:** Stripe PaymentIntent integration, plus placeholder for non‑Stripe methods.

---

## How to describe it in one paragraph for README

> LuxeCart is a full‑featured Ruby on Rails e‑commerce platform that showcases a modern shopping experience end‑to‑end. It includes a product catalog with rich category pages, a session‑based cart with AJAX quantity controls, a realistic checkout flow with address management and order summaries, and Stripe integration for payment processing. Orders are stored with detailed line‑item snapshots, and the codebase is structured to be extended into a complete admin dashboard and production‑ready online store.

If you want, I can now turn this into an actual `README.md` content block (with sections, badges, getting‑started steps, etc.) tailored to your repo.

admin password 
Email: admin@example.com
Password: securepassword