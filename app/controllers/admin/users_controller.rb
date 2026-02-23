module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:show, :block, :unblock, :make_admin, :revoke_admin]

    # GET /admin/users
    # Optional search via ?q=term (searches email, first_name, last_name)
    def index
      query = params[:q].to_s.strip

      users_scope =
        if query.present?
          # Use case-insensitive match; works with PostgreSQL and many DBs that support ILIKE.
          User.where("email ILIKE :q OR first_name ILIKE :q OR last_name ILIKE :q", q: "%#{query}%")
        else
          User.all
        end

      # Eager-load orders to avoid N+1 in index views that display order counts or recent orders.
      @users = users_scope.includes(:orders).order(created_at: :desc)
    end

    # GET /admin/users/:id
    def show
      # Load user's orders newest-first; eager-load order_items if admin show displays them.
      @orders = @user.orders.includes(:order_items).order(created_at: :desc)
    end

    # POST /admin/users/:id/block
    def block
      if acting_on_self?
        redirect_to admin_users_path, alert: "You cannot block your own account."
        return
      end

      if @user.block!
        redirect_to admin_users_path, notice: "User blocked."
      else
        redirect_to admin_users_path, alert: "Unable to block user."
      end
    end

    # POST /admin/users/:id/unblock
    def unblock
      if @user.unblock!
        redirect_to admin_users_path, notice: "User unblocked."
      else
        redirect_to admin_users_path, alert: "Unable to unblock user."
      end
    end

    # POST /admin/users/:id/make_admin
    def make_admin
      if acting_on_self?
        redirect_to admin_users_path, alert: "You already have admin rights."
        return
      end

      if @user.update(admin: true)
        redirect_to admin_users_path, notice: "User is now an admin."
      else
        redirect_to admin_users_path, alert: "Unable to grant admin rights."
      end
    end

    # POST /admin/users/:id/revoke_admin
    def revoke_admin
      if acting_on_self?
        redirect_to admin_users_path, alert: "You cannot revoke your own admin rights."
        return
      end

      if @user.update(admin: false)
        redirect_to admin_users_path, notice: "Admin rights revoked."
      else
        redirect_to admin_users_path, alert: "Unable to revoke admin rights."
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    # Prevent an admin from taking destructive/admin-rights actions on themselves.
    def acting_on_self?
      defined?(current_user) && @user == current_user
    end
  end
end