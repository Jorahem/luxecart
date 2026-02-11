module AdminPanel
  class BaseController < ApplicationController
    layout "admin"

    before_action :require_admin_login

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
  end
end