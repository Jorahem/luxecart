class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @recent_orders = @user.orders.order(created_at: :desc).limit(10)
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to profile_path, notice: 'Profile updated!'
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def user_params
    # Permit all fields you want to allow updates for
    params.require(:user).permit(:first_name, :last_name, :profile_image)
  end
end