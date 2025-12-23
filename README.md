# LuxeCart - E-commerce Platform

A full-featured e-commerce platform built with Ruby on Rails.

## Setup

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Setup database:
   ```bash
   rails db:create db:migrate db:seed
   ```

3. Configure environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your actual keys
   ```

4. Start the server:
   ```bash
   rails server
   ```

5. Visit http://localhost:3000

## Environment Variables

- `STRIPE_SECRET_KEY` - Your Stripe secret key
- `STRIPE_PUBLISHABLE_KEY` - Your Stripe publishable key
- `MAILER_SENDER` - Email sender address (default: noreply@luxecart.com)
- `CORS_ORIGINS` - Comma-separated list of allowed CORS origins
- `DATABASE_URL` - Database connection string (optional, defaults to SQLite)
- `REDIS_URL` - Redis connection URL for production caching

## Features

- User authentication with Devise
- Product catalog with categories and brands
- Shopping cart and checkout
- Stripe payment integration
- Product reviews and ratings
- Admin dashboard
- SEO-friendly URLs with FriendlyId
- Pagination with Kaminari

## Development

- Ruby version: 3.2.3
- Rails version: 7.1.6
- Database: SQLite (development), PostgreSQL (production recommended)

## Testing

Run the test suite:
```bash
rails test
```

Run system tests:
```bash
rails test:system
```

