require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  protect_from_forgery with: :exception
  rescue_from CanCan::AccessDenied, with: :unauthorized
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def set_breadcrumbs; end

  private

  def unauthorized
    flash[:alert] = 'Access denied.'
    redirect_to(request.referer || root_path)
  end
end
