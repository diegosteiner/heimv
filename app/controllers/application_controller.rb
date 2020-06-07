class ApplicationController < ActionController::Base
  responders :flash, :http_cache
  respond_to :html, :json

  protect_from_forgery with: :exception
  rescue_from CanCan::AccessDenied, with: :unauthorized
  before_action :configure_permitted_parameters, if: :devise_controller?
  default_form_builder BootstrapForm::FormBuilder
  helper_method :current_organisation

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def responder_flash_messages(resource_name, scope: :update)
    {
      notice: t(:notice, scope: %i[flash actions] + [scope], resource_name: resource_name),
      error: t(:error, scope: %i[flash actions] + [scope], resource_name: resource_name)
    }
  end

  def current_organisation
    @current_organisation ||= Organisation.current
  end

  private

  def unauthorized
    if current_user.nil?
      session[:next] = request.fullpath
      redirect_to login_url, alert: 'You are not authorized.'
    else
      redirect_to :back, alert: 'You are not authorized.'
    end
  end
end
