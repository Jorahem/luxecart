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
      @recent_orders = @user.orders.order(created_at: :desc).limit(10)
      render :show, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :profile_image)
  end
end