class DebugController < ApplicationController
  # Make this available in development only — remove after debugging
  before_action :ensure_dev_env

  # GET /dev/session_cart
  def session_cart
    render json: {
      session_cart: session[:cart] || {},
      cookies: request.cookies.slice(*request.cookies.keys), # full cookie map
      session_id_present: request.cookies.key?(Rails.application.config.session_options[:key].to_s)
    }
  end

  private

  def ensure_dev_env
    head :forbidden unless Rails.env.development?
  end
end