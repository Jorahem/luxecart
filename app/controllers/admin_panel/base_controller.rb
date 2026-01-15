module AdminPanel
  class BaseController < ApplicationController
    before_action :require_admin_login
    include Pundit

    helper_method :current_admin

    private

    def require_admin_login
      redirect_to admin_login_path, alert: "Please login" unless current_admin
    end

    def current_admin
      return @current_admin if defined?(@current_admin)
      if session[:admin_id]
        @current_admin = Admin.find_by(id: session[:admin_id])
      elsif cookies.signed[:admin_remember_token]
        token = cookies.signed[:admin_remember_token]
        @current_admin = Admin.find_by(remember_token: token)
        # ensure not expired
        if @current_admin && @current_admin.remember_token_expires_at < Time.current
          @current_admin = nil
        else
          session[:admin_id] = @current_admin.id if @current_admin
        end
      else
        nil
      end
    end

    # Basic activity logger helper
    def log_admin_action(action, trackable: nil, metadata: {})
      AdminActivity.create!(
        admin: current_admin,
        action: action,
        trackable: trackable,
        metadata: metadata,
        ip_address: request.remote_ip
      )
    rescue => e
      Rails.logger.error("Failed to log admin action: #{e.message}")
    end
  end
end