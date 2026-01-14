class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

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
end