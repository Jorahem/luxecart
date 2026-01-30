source "https://rubygems.org"

ruby "3.2.3"

# Core Rails
gem "rails", "~> 7.1.6"
gem "pg", ">= 1.4"
gem "puma", ">= 5.0"
gem "sprockets-rails"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"

# Auth & security
gem "devise"
gem "bcrypt", "~> 3.1"
gem "pundit"
gem "rack-attack"
gem "recaptcha", require: "recaptcha/rails"

# Background jobs & caching
gem "sidekiq"
gem "redis"   # needed for Sidekiq and caching

# URLs, pagination, charts
gem "friendly_id", "~> 5.5"
gem "kaminari", "1.2.2"
gem "chartkick"

# Styling / Frontend
gem "sassc-rails"
gem "hotwire-rails"
gem "tailwindcss-rails"

# File / images
gem "image_processing", "~> 1.2"

# Platform-specific
gem "tzinfo-data", platforms: %i[windows jruby]

# Boot optimization
gem "bootsnap", require: false

# Only needed in development and test
group :development, :test do
  gem "dotenv-rails" # env vars
end

group :development do
  gem "web-console"
  gem "debug", platforms: %i[mri windows]
  # Optional perf tools – enable only when investigating performance
  # gem "rack-mini-profiler"
  # gem "spring"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end