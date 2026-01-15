module AdminPanel
  class AdminController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin

    layout 'admin'

    private

    def require_admin
      unless current_user.role == 'admin'
        redirect_to root_path, alert: 'Access denied. Admin privileges required.'
      end
    end
  end
end