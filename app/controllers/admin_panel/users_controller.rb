module AdminPanel
  class UsersController < AdminPanel::BaseController
    before_action :set_user, only: %i[show edit update destroy toggle_admin]

    def index
      @users = User.order(created_at: :desc)
    end

    def show
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)

      if @user.save
        redirect_to admin_users_path, notice: "User created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      # If password fields are blank, don't overwrite password
      if params.dig(:user, :password).blank? && params.dig(:user, :password_confirmation).blank?
        filtered = user_params.except(:password, :password_confirmation)
      else
        filtered = user_params
      end

      if @user.update(filtered)
        redirect_to admin_users_path, notice: "User updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end


def destroy
  User.transaction do
    @user.destroy!
  end

  redirect_to admin_users_path, notice: "User deleted permanently."
rescue ActiveRecord::RecordNotDestroyed, ActiveRecord::InvalidForeignKey => e
  redirect_to admin_user_path(@user), alert: "Delete failed: #{e.message}"
end

    # PATCH /admin/users/:id/toggle_admin
    def toggle_admin
      unless @user.respond_to?(:admin)
        redirect_to admin_users_path, alert: "User model has no admin flag." and return
      end

      @user.update(admin: !@user.admin)
      redirect_to admin_users_path, notice: "Admin status updated."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
        :first_name,
        :last_name,
        :email,
        :password,
        :password_confirmation,
        :admin,
        :blocked
      )
    end
  end
end