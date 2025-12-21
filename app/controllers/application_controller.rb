class ApplicationController < ActionController::Base
  helper_method :current_cart

  private

  def current_cart
    if user_signed_in?
      @current_cart ||= current_user.cart || current_user.create_cart
    else
      # Use find_or_create_by to avoid race conditions
      @current_cart ||= Cart.find_or_create_by(session_id: session.id.to_s)
      session[:cart_id] = @current_cart.id
    end
  end

  def user_signed_in?
    session[:user_id].present?
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if user_signed_in?
  end
  
  helper_method :current_user, :user_signed_in?

  def require_login
    unless user_signed_in?
      redirect_to login_path, alert: "You must be logged in to access this section"
    end
  end
end
