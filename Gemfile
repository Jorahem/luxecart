source "https://rubygems.org"

ruby "3.2.2"

# Core Rails gems
gem "rails", "~> 7.1.0"
gem "sprockets-rails"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "redis", ">= 4.0.1"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false

# Authentication & Authorization
gem "devise", "~> 4.9"
gem "pundit", "~> 2.3"

# Payment Processing
gem "stripe", "~> 10.0"

# Search & Filtering
gem "ransack", "~> 4.1"
gem "pg_search", "~> 2.3"

# Pagination
gem "pagy", "~> 6.2"
gem "kaminari", "~> 1.2"

# Background Jobs
gem "sidekiq", "~> 7.2"

# File Upload & Processing
gem "image_processing", "~> 1.12"

# State Machine
gem "aasm", "~> 5.5"

# PDF Generation
gem "wicked_pdf", "~> 2.7"
gem "wkhtmltopdf-binary", "~> 0.12.6"

# SEO
gem "friendly_id", "~> 5.5"
gem "meta-tags", "~> 2.20"
gem "sitemap_generator", "~> 6.3"

# Security
gem "rack-attack", "~> 6.7"

# Environment Variables
gem "dotenv-rails", "~> 2.8"

# CSS & JavaScript
gem "tailwindcss-rails", "~> 2.3"
gem "cssbundling-rails", "~> 1.3"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.2"
  gem "pry-rails", "~> 0.3"
  gem "bullet", "~> 7.1"
end

group :development do
  gem "web-console"
  gem "letter_opener", "~> 1.9"
end

group :test do
  gem "capybara", "~> 3.39"
  gem "selenium-webdriver", "~> 4.16"
  gem "shoulda-matchers", "~> 6.0"
  gem "database_cleaner-active_record", "~> 2.1"
  gem "simplecov", "~> 0.22", require: false
end
