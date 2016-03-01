class AdminController < ApplicationController

  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_user
  after_action  :verify_authorized

  add_breadcrumb "Admin", :admin_path

  layout "admin"

  def index
  end

  private

    # is this necessary? :verify_authorized is already called
    def authorize_user
      authorize :admin, :site_admin?
    end

    def set_user
      @user = current_user
    end

end