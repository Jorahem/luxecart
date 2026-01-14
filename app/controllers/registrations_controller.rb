class RegistrationsController < Devise::RegistrationsController
  private

  # If you override sign_up_params / account_update_params, ensure names are allowed:
  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password)
  end
end