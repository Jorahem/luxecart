module AdminPanel
  class DashboardController < AdminPanel::BaseController
    # Keep your admin layout
    layout "admin"

    def index
      # You can add dashboard logic here (stats, etc.)
    end

    private

    # Kept from your old code (no longer used as a before_action, but preserved safely)
    # If you still want session-based Admin login, we can switch BaseController to use this.
    def require_admin_login
      unless current_admin
        redirect_to admin_login_path, alert: "Please sign in."
      end
    end

    # Kept from your old code for compatibility with any dashboard views/partials
    # that might call current_admin.
    def current_admin
      # Use your old session-based admin if you have an Admin model/table
      @current_admin ||= (Admin.find_by(id: session[:admin_id]) rescue nil)
    end

    helper_method :current_admin
  end
end