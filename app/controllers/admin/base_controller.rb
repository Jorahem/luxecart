module Admin
  class BaseController < ApplicationController
    layout "admin"

    before_action :authenticate_user!
    before_action :authenticate_admin!

    private

    def authenticate_admin!
      is_admin =
        if current_user.respond_to?(:admin)
          !!current_user.admin
        else
          false
        end

      unless is_admin
        flash[:alert] = "You are not authorized to access this area."
        redirect_to root_path
      end
    end
  end
end