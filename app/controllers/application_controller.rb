# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception
  rescue_from Pundit::NotAuthorizedError, with: :unauthorized
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_breadcrumbs

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
