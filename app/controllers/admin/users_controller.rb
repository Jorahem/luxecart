module Admin
  class UsersController < AdminController
    before_action :set_user, only: [:show, :edit, :update, :destroy]

    def index
      @users = User.order(created_at: :desc).page(params[:page]).per(20)
      @users = @users.where(role: params[:role]) if params[:role].present?
    end

    def show
      @orders = @user.orders.recent.limit(10)
      @reviews = @user.reviews.recent.limit(10)
    end

    def edit
    end

    def update
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: 'User was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path, notice: 'User was successfully deleted.'
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :phone, :role)
    end
  end
end
