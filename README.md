# Luxecart - Professional E-commerce Platform

A modern, professional e-commerce website built with Ruby on Rails featuring product management, shopping cart, checkout, and order management.

## Features

### Customer Features
- 🏠 **Modern Homepage** - Featured products, categories, and new arrivals
- 🔍 **Product Catalog** - Browse products with filters and sorting
- 🛒 **Shopping Cart** - Add/remove items, update quantities
- 💳 **Checkout System** - Simple checkout with order confirmation
- 📦 **Order History** - View and track all your orders
- 👤 **User Authentication** - Secure login and registration
- 📱 **Responsive Design** - Works on all devices

### Admin Features
- 📊 **Dashboard** - Overview of orders, products, and statistics
- 📦 **Product Management** - Create, edit, and delete products
- 🖼️ **Image Upload** - Multiple image support with Active Storage
- 📋 **Order Management** - View and update order status
- 🚚 **Order Tracking** - Mark orders as shipped/delivered

## Setup Instructions

### Prerequisites
- Ruby 3.2.3
- Rails 7.1.6
- SQLite3

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Jorahem/luxecart.git
   cd luxecart
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Set up the database**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. **Start the server**
   ```bash
   rails server
   ```

5. **Visit the application**
   - Store: http://localhost:3000
   - Admin Panel: http://localhost:3000/admin

## Default Credentials

### Admin Account
- **Email:** admin@luxecart.com
- **Password:** password123

### Customer Account
- **Email:** user@example.com
- **Password:** password123

## Usage Guide

### For Customers

1. **Browse Products**
   - Visit the homepage to see featured products
   - Click "Products" to browse all products
   - Use filters to find specific items

2. **Add to Cart**
   - Click "Add to Cart" on any product
   - Adjust quantities in the cart
   - Proceed to checkout when ready

3. **Place an Order**
   - Log in or create an account
   - Review your cart
   - Complete checkout
   - View order confirmation

4. **Track Orders**
   - Go to "My Orders" to see all your orders
   - Click on an order to view details
   - Cancel pending orders if needed

### For Administrators

1. **Access Admin Panel**
   - Log in with admin credentials
   - Click "Admin Panel" in the header

2. **Manage Products**
   - Click "Products" in admin sidebar
   - Add new products with images
   - Edit or delete existing products
   - Toggle featured status

3. **Manage Orders**
   - View all orders in the system
   - Update order status
   - Add tracking numbers
   - Mark orders as shipped/delivered

## Project Structure

```
app/
├── controllers/
│   ├── admin/              # Admin controllers
│   ├── application_controller.rb
│   ├── products_controller.rb
│   ├── carts_controller.rb
│   ├── orders_controller.rb
│   └── checkout_controller.rb
├── models/
│   ├── product.rb
│   ├── order.rb
│   ├── cart.rb
│   └── user.rb
└── views/
    ├── layouts/
    │   ├── application.html.erb  # Main layout
    │   └── admin.html.erb        # Admin layout
    ├── home/
    ├── products/
    ├── carts/
    ├── orders/
    └── admin/
```

## Key Technologies

- **Ruby on Rails 7.1** - Web framework
- **SQLite3** - Database
- **Active Storage** - File uploads
- **BCrypt** - Password encryption
- **Turbo & Stimulus** - Modern JavaScript

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is open source and available under the MIT License.

## Support

For issues and questions, please create an issue in the GitHub repository.

---

Made with ❤️ by the Luxecart Team
