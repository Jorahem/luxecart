class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_cart

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [:first_name, :last_name, :phone]
    )

    devise_parameter_sanitizer.permit(
      :account_update,
      keys: [:first_name, :last_name, :phone]
    )
  end

  def current_cart
    @current_cart ||= Cart.find_by(id: session[:cart_id])
  end
end
