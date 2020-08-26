# frozen_string_literal: true

class ApplicationController < ActionController::Base
  responders :flash, :http_cache
  respond_to :html, :json

  protect_from_forgery with: :exception
  rescue_from CanCan::AccessDenied, with: :unauthorized
  default_form_builder BootstrapForm::FormBuilder
  before_action :set_raven_context
  helper_method :current_organisation
  before_action do
    Rack::MiniProfiler.authorize_request if current_user&.role_admin?
  end

  def default_url_options
    { org: params[:org] }.merge(super)
  end

  protected

  def responder_flash_messages(resource_name, scope: :update)
    {
      notice: t(:notice, scope: %i[flash actions] + [scope], resource_name: resource_name),
      error: t(:error, scope: %i[flash actions] + [scope], resource_name: resource_name)
    }
  end

  def current_organisation
    nil
  end

  def set_raven_context
    return unless defined?(Raven)

    Raven.user_context(id: current_user&.email)
    Raven.extra_context(params: params.to_unsafe_h, url: request.url, organisation: current_organisation&.name)
  end

  def unauthorized
    if current_user.nil?
      session[:next] = request.fullpath
      redirect_to login_url, alert: t('unauthorized')
    else
      redirect_back alert: t('unauthorized'), fallback_location: root_path
      raise 'unauthorized'
    end
  end
end
