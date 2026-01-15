module AdminPanel
  class SessionsController < BaseController
    layout "admin"

    # Allow unauthenticated access to the login form and submit action
    skip_before_action :require_admin_login, only: [:new, :create]
    # If you use Pundit verify_authorized in BaseController, also skip it here:
    # skip_after_action :verify_authorized, only: [:new, :create] if respond_to?(:verify_authorized)

    def new
      redirect_to admin_dashboard_path if current_admin
    end

    def create
      admin = Admin.find_by(email: params[:email]&.downcase)

      if admin&.authenticate(params[:password]) && !admin.locked
        session[:admin_id] = admin.id

        if params[:remember_me] == "1"
          token = admin.set_remember_token!(expires_in: 30.days)
          cookies.signed[:admin_remember_token] = { value: token, expires: 30.days, httponly: true }
        end

        log_admin_action("login", metadata: { user_agent: request.user_agent })

        redirect_to admin_dashboard_path, notice: "Signed in"
      else
        if admin
          admin.increment!(:failed_attempts)
          admin.update!(locked: true) if admin.failed_attempts >= 5
        end

        flash.now[:alert] = "Invalid email or password"
        render :new, status: :unauthorized
      end
    end

    def destroy
      if current_admin
        log_admin_action("logout")
        current_admin.clear_remember_token!
      end

      session[:admin_id] = nil
      cookies.delete(:admin_remember_token)
      redirect_to admin_login_path, notice: "Signed out"
    end
  end
end


