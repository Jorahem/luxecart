# config/initializers/session_store.rb
Rails.application.config.session_store :cookie_store,
  key: '_luxecart_session',
  same_site: :lax,
  secure: Rails.env.production? # keep secure only in production
# DO NOT set `domain:` unless you need it; leave nil in development