class Rack::Attack
  # Throttle all requests by IP
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip
  end

  # Throttle login attempts by email
  throttle('logins/email', limit: 5, period: 20.seconds) do |req|
    if req.path == '/users/sign_in' && req.post?
      req.params['email'].to_s.downcase.gsub(/\s+/, "")
    end
  end

  # Throttle API requests
  throttle('api/ip', limit: 100, period: 1.minute) do |req|
    req.ip if req.path.start_with?('/api/')
  end
end
