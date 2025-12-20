Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*' # Change in production to specific domains
    
    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: false
  end
end
