module AdminPanel
  class DashboardController < ApplicationController
    layout 'admin'
    before_action :require_admin_login

    def index
      # You can add dashboard logic here (stats, etc.)
    end

    private

    def require_admin_login
      unless current_admin
        redirect_to admin_login_path, alert: "Please sign in."
      end
    end

    def current_admin
      @current_admin ||= Admin.find_by(id: session[:admin_id])
    end

    helper_method :current_admin
  end
end