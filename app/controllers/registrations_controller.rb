class RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!

  after_action  :verify_authorized, only: [:edit, :update]

  respond_to :json

  layout "authentication"

  def edit
    authorize @user

    set_minimum_password_length

    add_breadcrumb "Edit Profile", edit_user_registration_path
  end

  def update
    authorize @user

    successfully_updated = if needs_password?(@user, params)
      @user.update_with_password(devise_parameter_sanitizer.sanitize(:account_update))
    else
      # remove the virtual current_password attribute
      # update_without_password doesn't know how to ignore it
      params[:user].delete(:current_password)

      @user.update_without_password(devise_parameter_sanitizer.sanitize(:account_update))
    end

    if successfully_updated
      set_flash_message :notice, :updated

      # sign in the user bypassing validation in case their password changed
      sign_in @user, :bypass => true

      redirect_to after_update_path_for(@user)
    else
      render "edit"
    end
  end

  protected

    def after_update_path_for(resource)
      edit_user_registration_path
    end

    def after_sign_up_path_for(resource)
      stored_location_for(resource) || sites_url
    end

    def after_sign_in_path_for(resource)
      sign_in_url = new_user_session_url
      if request.referer == sign_in_url
        super
      else
        stored_location_for(resource) || sites_url
      end
    end

  private

    # check if we need password to update user data
    # ie if password or email was changed
    # extend this as needed
    def needs_password?(user, params)
      (params[:user][:email].present? && user.email != params[:user][:email]) ||
          params[:user][:password].present? ||
          params[:user][:password_confirmation].present?
    end
end