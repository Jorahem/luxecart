class ApplicationController < ActionController::Base
  include Pundit

  before_action :configure_permitted_parameters, if: :devise_controller?

  # Pundit: handle unauthorized access centrally
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  # Permit extra Devise params (if you need this)
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  end

  # Called by Devise after a successful sign in.
  # Set a friendly flash and then delegate to Devise's default path.
  def after_sign_in_path_for(resource_or_scope)
    name = display_name_for(resource_or_scope)
    flash[:notice] = "Welcome back, #{name}!"
    super
  end

  # Called by Devise after sign up (used by RegistrationsController)
  def after_sign_up_path_for(resource)
    name = display_name_for(resource)
    flash[:notice] = "Welcome to LuxeCart, #{name}! 🎉"
    super(resource)
  end

  private

  # Helper to build a friendly name: prefer first_name, last_name, then email
  def display_name_for(resource)
    return "" unless resource
    if resource.respond_to?(:first_name) && resource.respond_to?(:last_name)
      ([resource.first_name, resource.last_name].compact.join(" ").presence || resource.email)
    elsif resource.respond_to?(:name) && resource.name.present?
      resource.name
    else
      resource.try(:email) || "there"
    end
  end

  # Return the current cart; persist in session or associate with current_user.
  # Makes a cart for guest users and reuses a persisted cart for signed-in users.
  def current_cart
    return @current_cart if defined?(@current_cart) && @current_cart

    # If user is signed in, prefer a persisted cart on the user
    if respond_to?(:user_signed_in?) && user_signed_in?
      @current_cart = current_user.cart || current_user.create_cart
      session[:cart_id] = @current_cart.id
      return @current_cart
    end

    # Guest user: use session[:cart_id]
    if session[:cart_id].present?
      @current_cart = Cart.find_by(id: session[:cart_id]) || Cart.create.tap { |c| session[:cart_id] = c.id }
    else
      @current_cart = Cart.create
      session[:cart_id] = @current_cart.id
    end

    @current_cart
  end
  helper_method :current_cart

  # Pundit unauthorized handler
  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end
end