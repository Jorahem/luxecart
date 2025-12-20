source "https://rubygems.org"

ruby "3.2.3"

# Core Rails
gem "rails", "~> 7.1.6"
gem "sprockets-rails"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "bootsnap", require: false

# Database
gem "sqlite3", ">= 1.4" # Development/Test
gem "pg", "~> 1.5"      # Production ready

# Authentication & Authorization - CRITICAL
gem "devise", "~> 4.9"
gem "pundit", "~> 2.3"

# URL Slugs - CRITICAL (used in Brand, Product, Category models)
gem "friendly_id", "~> 5.5"

# Search - CRITICAL (used in Product model)
gem "pg_search", "~> 2.3"

# Pagination - CRITICAL (used in ALL controllers)
gem "kaminari", "~> 1.2"

# Payment Processing - CRITICAL (used in Checkout)
gem "stripe", "~> 10.0"

# Image Processing
gem "image_processing", "~> 1.12"

# Money & Currency
gem "money-rails", "~> 1.15"

# Background Jobs
gem "sidekiq", "~> 7.0"
gem "redis", "~> 5.0"

# API & CORS
gem "rack-cors"

# Security
gem "rack-attack", "~> 6.7"

# Environment Variables
gem "dotenv-rails", groups: [:development, :test]

# Admin Panel (Optional but useful)
gem "activeadmin", "~> 3.2"

# AWS for file uploads
gem "aws-sdk-s3", "~> 1.0", require: false

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
  gem "rspec-rails", "~> 6.0"
  gem "factory_bot_rails", "~> 6.2"
  gem "faker", "~> 3.2"
end

group :development do
  gem "web-console"
  gem "annotate", "~> 3.2"
  gem "bullet", "~> 7.1" # N+1 query detection
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "shoulda-matchers", "~> 5.3"
end
