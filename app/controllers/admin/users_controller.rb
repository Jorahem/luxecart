module Admin
  class UsersController < AdminController
    before_action :set_user, only: [:show, :edit, :update, :destroy, :toggle_admin]

    def index
      @users = User.all
      @users = @users.where(role: params[:role]) if params[:role].present?
      @users = @users.order(created_at: :desc).page(params[:page]).per(20)
    end

    def show
      @orders = @user.orders.order(created_at: :desc).limit(10)
      @reviews = @user.reviews.order(created_at: :desc).limit(10)
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
      redirect_to admin_users_url, notice: 'User was successfully deleted.'
    end

    def toggle_admin
      new_role = @user.admin? ? 'customer' : 'admin'
      @user.update(role: new_role)
      redirect_to admin_users_path, notice: "User role changed to #{new_role}."
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
