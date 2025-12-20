class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_cart
  helper_method :current_cart

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::RoutingError, with: :render_404

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone])
  end

  def set_cart
    @cart = current_cart if user_signed_in?
  end

  def current_cart
    return nil unless user_signed_in?
    @current_cart ||= current_user.cart || current_user.create_cart
  end

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: 'Access denied. Admin privileges required.'
    end
  end

  private

  def record_not_found
    render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false
  end

  def render_404
    render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false
  end
end
