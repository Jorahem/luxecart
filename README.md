# LuxeCart - Complete Ruby on Rails E-Commerce Platform

A modern, full-featured e-commerce platform built with Ruby on Rails.

## Features

### Customer Features
- Product browsing with advanced search and filters
- Shopping cart (guest and user carts)
- Stripe payment integration
- Order tracking and history
- Product reviews and ratings
- Wishlist functionality
- User account management
- Address book

### Admin Features
- Comprehensive dashboard with analytics
- Product management (CRUD operations)
- Order processing and fulfillment
- User management
- Coupon/discount management
- Review moderation
- Category and brand management

## Technology Stack

- **Ruby**: 3.2+
- **Rails**: 7.1+
- **Database**: PostgreSQL
- **CSS**: Tailwind CSS
- **JavaScript**: Hotwire (Turbo + Stimulus)
- **Payment**: Stripe
- **Background Jobs**: Sidekiq
- **Image Processing**: Active Storage

## Setup Instructions

### Prerequisites

- Ruby 3.2 or higher
- PostgreSQL 14 or higher
- Redis (for Sidekiq)
- Node.js and Yarn

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Jorahem/luxecart.git
cd luxecart
```

2. Install dependencies:
```bash
bundle install
yarn install
```

3. Setup environment variables:
```bash
cp .env.example .env
# Edit .env with your credentials
```

4. Setup database:
```bash
rails db:create
rails db:migrate
rails db:seed
```

5. Start the server:
```bash
bin/dev
```

## Default Admin Credentials

- Email: admin@luxecart.com
- Password: Password123!

## License

MIT License
