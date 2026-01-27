module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    private

    def authenticate_admin!
      unless current_user&.admin?
        flash[:alert] = "You are not authorized to access this area."
        redirect_to root_path
      end
    end
  end
end