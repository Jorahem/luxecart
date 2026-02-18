module AdminPanel
  class BaseController < ApplicationController
    layout "admin_panel"
    before_action :require_admin_login
    before_action :set_unseen_order_count    # <-- Correct place!

    helper_method :current_admin, :admin_signed_in?

    private

    def current_admin
      @current_admin ||= Admin.find_by(id: session[:admin_id])
    rescue StandardError
      nil
    end

    def admin_signed_in?
      current_admin.present?
    end

    def require_admin_login
      return if admin_signed_in?
      redirect_to admin_login_path, alert: "Please sign in as admin."
    end

    def set_unseen_order_count               # <-- also here, inside the class
      @unseen_order_count = Order.where(admin_seen: false).count
    end
  end
end