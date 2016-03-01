class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :configure_devise_permitted_parameters, if: :devise_controller?

  layout :layout_by_resource

  def layout_by_resource
    if devise_controller? #&& resource_name == :user && action_name == 'new'
      "authentication"
    end
  end

  protected

    def configure_devise_permitted_parameters
      registration_params = [:email, :password, :password_confirmation]
      personal_information_params = [:first_name, :last_name]

      global_params = (registration_params + personal_information_params)

      if params[:action] == 'update'
        devise_parameter_sanitizer.for(:account_update) {
            |u| u.permit(global_params << :current_password)
        }
      elsif params[:action] == 'create'
        devise_parameter_sanitizer.for(:sign_up) {
            |u| u.permit(global_params)
        }
      end
    end

  private

    def user_not_authorized
      flash[:error] = "You are not authorized to perform this action."
      redirect_to(request.referrer || root_path)
    end

end
