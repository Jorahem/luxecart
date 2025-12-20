class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :current_cart

  private

  def current_cart
    if user_signed_in?
      @current_cart ||= current_user.cart || current_user.create_cart
    else
      @current_cart ||= Cart.find_or_create_by(session_id: session.id.to_s)
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone])
  end
end
