# LuxeCart - Premium E-Commerce Platform

A fully functional, production-ready e-commerce platform built with Ruby on Rails.

## Features

- **Customer Features:**
  - Product browsing with advanced filtering and search
  - Shopping cart and wishlist functionality
  - Secure checkout with Stripe payment integration
  - Order tracking and history
  - Product reviews and ratings
  - User authentication with Devise
  - Multiple shipping addresses management
  - Coupon code support

- **Admin Features:**
  - Comprehensive admin dashboard with analytics
  - Product, category, and brand management
  - Order management and status updates
  - User management
  - Coupon management
  - Review moderation
  - Low stock alerts
  - Inventory management

## Tech Stack

- **Ruby:** 3.2.3
- **Rails:** 7.1.6
- **Database:** SQLite3 (development), PostgreSQL recommended for production
- **Authentication:** Devise
- **Payment Processing:** Stripe
- **Pagination:** Kaminari
- **Search:** Ransack
- **Image Processing:** Active Storage with image_processing
- **PDF Generation:** WickedPDF
- **Friendly URLs:** FriendlyId

## Prerequisites

- Ruby 3.2.3
- Rails 7.1.6
- Node.js (for JavaScript)
- Yarn or npm
- SQLite3 (development)

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Jorahem/luxecart.git
   cd luxecart
   ```

2. **Install Ruby dependencies:**
   ```bash
   bundle install
   ```

3. **Install JavaScript dependencies:**
   ```bash
   yarn install
   # or
   npm install
   ```

4. **Setup database:**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

5. **Setup environment variables:**
   
   Create a `.env` file in the root directory (or set environment variables):
   ```
   STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key
   STRIPE_SECRET_KEY=your_stripe_secret_key
   ```

   For development, you can use Stripe test keys available at https://stripe.com/docs/keys

## Running the Application

Start the Rails server:

```bash
rails server
```

Visit http://localhost:3000 in your browser.

## Login Credentials

After running `rails db:seed`, you can login with:

**Admin Account:**
- Email: admin@luxecart.com
- Password: password123

**Customer Account:**
- Email: customer@example.com
- Password: password123

## Admin Dashboard

Access the admin dashboard at: http://localhost:3000/admin

You must be logged in as an admin user.

## Stripe Payment Configuration

### Development Mode

1. Sign up for a Stripe account at https://stripe.com
2. Get your test API keys from the Stripe Dashboard
3. Add keys to your environment variables (`.env` file or system environment)
4. Test payments using Stripe test card numbers:
   - Success: `4242 4242 4242 4242`
   - Decline: `4000 0000 0000 0002`
   - Any future expiry date and any 3-digit CVC

### Production Mode

1. Use your Stripe live keys
2. Enable your Stripe account for production
3. Configure webhooks for payment confirmations

## Database Schema

Key models include:
- **User** - Customer and admin accounts with role-based access
- **Product** - Product catalog with variants and images
- **Category** - Hierarchical product categories
- **Brand** - Product brands
- **Order** - Customer orders with multiple items
- **Cart** - Shopping cart (session or user-based)
- **Wishlist** - User wishlists
- **Review** - Product reviews with moderation
- **Coupon** - Discount coupons
- **Address** - Customer shipping addresses

## Testing

Run the test suite (when tests are implemented):

```bash
# Run all tests
rails test

# Or with RSpec
bundle exec rspec
```

## Deployment

### Heroku Deployment

1. **Create Heroku app:**
   ```bash
   heroku create your-app-name
   ```

2. **Add PostgreSQL database:**
   ```bash
   heroku addons:create heroku-postgresql:mini
   ```

3. **Set environment variables:**
   ```bash
   heroku config:set STRIPE_PUBLISHABLE_KEY=your_key
   heroku config:set STRIPE_SECRET_KEY=your_secret_key
   heroku config:set RAILS_MASTER_KEY=your_master_key
   ```

4. **Deploy:**
   ```bash
   git push heroku main
   heroku run rails db:migrate
   heroku run rails db:seed
   ```

### Docker Deployment

Build and run using Docker:

```bash
docker build -t luxecart .
docker run -p 3000:3000 luxecart
```

## Project Structure

```
luxecart/
├── app/
│   ├── controllers/      # Application controllers
│   │   ├── admin/        # Admin namespace controllers
│   │   └── ...
│   ├── models/           # ActiveRecord models
│   ├── views/            # ERB templates
│   │   ├── admin/        # Admin views
│   │   ├── layouts/      # Layout templates
│   │   └── ...
│   ├── helpers/          # View helpers
│   └── mailers/          # Action Mailer classes
├── config/
│   ├── initializers/     # Configuration files
│   └── routes.rb         # Application routes
├── db/
│   ├── migrate/          # Database migrations
│   └── seeds.rb          # Seed data
└── public/               # Static files
```

## Key Features Implementation

### Product Search & Filtering
- Full-text search across product name, description, and SKU
- Filter by category, brand, price range
- Sort by price, popularity, and date

### Shopping Cart
- Session-based cart for guests
- User-associated cart for logged-in customers
- Automatic cart persistence

### Order Processing
1. Customer adds items to cart
2. Proceeds to checkout
3. Selects shipping address
4. Chooses payment method
5. Order is created and payment processed via Stripe
6. Email confirmation sent (when mailers are configured)
7. Admin can update order status

### Admin Dashboard
- Real-time statistics (revenue, orders, customers, products)
- Recent orders overview
- Low stock alerts
- Pending reviews moderation

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is available as open source under the terms of the MIT License.

## Support

For support, email support@luxecart.com or open an issue on GitHub.

## Roadmap

Future enhancements planned:
- [ ] Advanced analytics and reporting
- [ ] Multiple payment gateway support
- [ ] Multi-language support
- [ ] Product recommendations engine
- [ ] Email marketing integration
- [ ] Mobile app (React Native)
- [ ] Advanced inventory management
- [ ] Wholesale/B2B features
- [ ] Multi-vendor marketplace support

## Acknowledgments

- Built with Ruby on Rails
- Payment processing by Stripe
- Icons and design inspiration from various sources

