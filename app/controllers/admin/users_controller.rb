module Admin
  class UsersController < AdminController
    before_action :set_user, only: [:show, :edit, :update, :destroy]

    def index
      @users = User.order(created_at: :desc).page(params[:page]).per(20)
    end

    def show
      @orders = @user.orders.order(created_at: :desc).limit(10)
    end

    def edit
    end

    def update
      if @user.update(user_params)
        redirect_to admin_users_path, notice: 'User updated successfully.'
      else
        render :edit
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path, notice: 'User deleted successfully.'
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :role)
    end
  end
end
