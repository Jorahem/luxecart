module AdminPanel
  class SessionsController < ApplicationController
    layout 'admin'

    def new
    end

    def create
      admin = Admin.find_by(email: params[:email].to_s.downcase)
      if admin&.authenticate(params[:password]) && !admin.locked?
        session[:admin_id] = admin.id
        redirect_to admin_dashboard_path, notice: "Welcome, #{admin.email}!"
      else
        flash.now[:alert] = "Incorrect email or password, or account locked."
        render :new, status: :unauthorized
      end
    end

    def destroy
      session[:admin_id] = nil
      redirect_to admin_login_path, notice: "Logged out."
    end
  end
end