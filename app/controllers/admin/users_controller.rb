module Admin
  class UsersController < BaseController
    def index
      @users = User.all.order(created_at: :desc)
    end

    def show
      @user = User.find(params[:id])
      @orders = @user.orders
    end

    def block
      user = User.find(params[:id])
      user.block!
      redirect_to admin_users_path, notice: "User blocked."
    end

    def unblock
      user = User.find(params[:id])
      user.unblock!
      redirect_to admin_users_path, notice: "User unblocked."
    end

    def make_admin
      user = User.find(params[:id])
      user.update(admin: true)
      redirect_to admin_users_path, notice: "User is now admin."
    end

    def revoke_admin
      user = User.find(params[:id])
      user.update(admin: false)
      redirect_to admin_users_path, notice: "Admin rights revoked."
    end
  end
end