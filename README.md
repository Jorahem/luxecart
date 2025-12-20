# 🛍️ LuxeCart - Premium E-Commerce Platform

LuxeCart is a full-featured e-commerce platform built with Ruby on Rails 7.1. It provides a complete shopping experience with advanced features for both customers and administrators.

## ✨ Features

### Customer Features
- 🔐 **User Authentication** - Secure registration and login with Devise
- 🛒 **Shopping Cart** - Add, update, and remove items
- ❤️ **Wishlist** - Save products for later
- 🔍 **Advanced Search** - Full-text search with filters (category, brand, price range, availability)
- ⭐ **Product Reviews** - Rate and review products
- 📦 **Order Management** - View order history and track orders
- 💳 **Stripe Integration** - Secure payment processing
- 🎫 **Coupon System** - Apply discount codes
- 📍 **Multiple Addresses** - Manage shipping and billing addresses
- 📱 **Responsive Design** - Works on desktop, tablet, and mobile

### Admin Features
- 📊 **Analytics Dashboard** - Sales metrics, revenue, and performance data
- 📦 **Product Management** - Full CRUD for products with variants and images
- 👥 **User Management** - Manage customers and admins
- 📋 **Order Management** - Process orders and update status
- 🏷️ **Category & Brand Management** - Organize products
- ⭐ **Review Moderation** - Approve or reject customer reviews
- 🎫 **Coupon Management** - Create and manage discount codes
- 📉 **Low Stock Alerts** - Monitor inventory levels

### Advanced Features
- 🤖 **Recommendation Engine** - Similar products, frequently bought together, personalized recommendations
- 📧 **Email Notifications** - Order confirmation, shipping updates, welcome emails
- 🔒 **Security** - Rate limiting, CSRF protection, SQL injection prevention
- 🌐 **RESTful API** - JSON API for third-party integrations (v1)
- 💰 **Money Handling** - Proper currency formatting with money-rails
- 🔎 **SEO-Friendly URLs** - Friendly IDs for products, categories, and brands
- 📄 **Pagination** - Kaminari pagination for all listings

## 🛠️ Technology Stack

- **Ruby** 3.2.3
- **Rails** 7.1.6
- **Database** SQLite3 (development/test), PostgreSQL (production)
- **Authentication** Devise
- **Authorization** Pundit
- **Search** PgSearch
- **Pagination** Kaminari
- **Payment** Stripe
- **Image Processing** ImageProcessing, MiniMagick
- **Background Jobs** Sidekiq
- **Caching** Redis
- **API** RESTful JSON API
- **Security** Rack::Attack, Rack::CORS

## 📋 Prerequisites

- Ruby 3.2.3
- Rails 7.1.6
- SQLite3 (for development)
- PostgreSQL (for production)
- Redis (for caching and background jobs)
- ImageMagick (for image processing)

## 🚀 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/luxecart.git
   cd luxecart
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup environment variables**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and configure:
   - Database credentials
   - Stripe API keys
   - SMTP settings
   - AWS S3 credentials (for production)
   - Redis URL

4. **Setup database**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

5. **Start the server**
   ```bash
   rails server
   ```

6. **Visit the application**
   - Main site: http://localhost:3000
   - Admin panel: http://localhost:3000/admin

## 🔑 Default Credentials

### Admin Account
- Email: `admin@luxecart.com`
- Password: `Password123!`

### Sample User Account
- Email: `user1@example.com`
- Password: `password123`

## 🌱 Seeding Data

The seed file creates:
- 1 Admin user
- 5 Sample users
- 8 Brands
- 4 Main categories with subcategories
- 10+ Products with various attributes
- 3 Active coupons
- Sample reviews

Run `rails db:seed` to populate the database.

## 📝 Environment Variables

Required environment variables (see `.env.example`):

```
# Database
DATABASE_URL=postgresql://username:password@localhost/luxecart_development

# Stripe
STRIPE_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxx
STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxx

# AWS S3 (Production)
AWS_ACCESS_KEY_ID=xxxxxxxxxxxxx
AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxx
AWS_REGION=us-east-1
AWS_BUCKET=luxecart-production

# Email (SMTP)
SMTP_ADDRESS=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USERNAME=apikey
SMTP_PASSWORD=xxxxxxxxxxxxx
DEFAULT_EMAIL_FROM=noreply@luxecart.com

# Redis
REDIS_URL=redis://localhost:6379/1

# Application
APP_HOST=localhost:3000
APP_NAME=LuxeCart
SECRET_KEY_BASE=xxxxxxxxxxxxx

# Admin
ADMIN_EMAIL=admin@luxecart.com
ADMIN_PASSWORD=Password123!
```

## 🧪 Running Tests

```bash
# Run all tests
rails test

# Run specific test file
rails test test/models/product_test.rb

# Run system tests
rails test:system
```

## 🚢 Deployment

### Production Setup

1. **Configure PostgreSQL**
   ```bash
   # Update DATABASE_URL in production environment
   ```

2. **Setup Redis**
   ```bash
   # Configure REDIS_URL for caching and Sidekiq
   ```

3. **Configure AWS S3**
   ```bash
   # Set AWS credentials for file uploads
   ```

4. **Setup Stripe**
   ```bash
   # Configure Stripe webhooks for production
   ```

5. **Precompile assets**
   ```bash
   RAILS_ENV=production rails assets:precompile
   ```

6. **Run migrations**
   ```bash
   RAILS_ENV=production rails db:migrate
   ```

## 📚 API Documentation

### Base URL
```
http://localhost:3000/api/v1
```

### Endpoints

#### Products
- `GET /api/v1/products` - List all products (with filters)
- `GET /api/v1/products/:id` - Get product details

#### Categories
- `GET /api/v1/categories` - List all categories
- `GET /api/v1/categories/:id` - Get category with products

#### Brands
- `GET /api/v1/brands` - List all brands
- `GET /api/v1/brands/:id` - Get brand with products

### Query Parameters

**Products:**
- `query` - Search term
- `category_id` - Filter by category
- `brand_id` - Filter by brand
- `min_price` - Minimum price
- `max_price` - Maximum price
- `sort` - Sort by (price_asc, price_desc, newest, popular, rating)
- `in_stock_only` - Only in-stock products (true/false)
- `on_sale_only` - Only sale items (true/false)
- `page` - Page number
- `per_page` - Items per page

## 🔒 Security Features

- **Rate Limiting** - Rack::Attack protects against abuse
- **CSRF Protection** - Rails built-in CSRF protection
- **SQL Injection Prevention** - ActiveRecord parameterized queries
- **XSS Protection** - Rails HTML escaping
- **Authentication** - Devise secure password hashing
- **Authorization** - Pundit policy-based authorization
- **HTTPS** - Force SSL in production

## 📊 Database Schema

Key models:
- **User** - Customers and admins
- **Product** - Products with variants and images
- **Category** - Hierarchical categories
- **Brand** - Product brands
- **Order** - Customer orders
- **OrderItem** - Items in an order
- **Cart** - Shopping cart
- **CartItem** - Items in cart
- **Wishlist** - User wishlist
- **Review** - Product reviews
- **Coupon** - Discount codes
- **Address** - Shipping/billing addresses

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- Your Name - Initial work

## 🙏 Acknowledgments

- Rails community for excellent documentation
- All gem contributors
- Open source community

## 📞 Support

For support, email support@luxecart.com or open an issue on GitHub.

---

Made with ❤️ using Ruby on Rails
