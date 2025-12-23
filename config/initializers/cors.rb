Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch('CORS_ORIGINS', 'localhost:3000').split(',')
    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
