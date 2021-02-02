# frozen_string_literal: true

class ApplicationController < ActionController::Base
  responders :flash, :http_cache
  respond_to :html, :json

  protect_from_forgery with: :exception
  rescue_from CanCan::AccessDenied, with: :unauthorized unless Rails.env.development?
  rescue_from ActiveRecord::RecordNotFound, ActionController::RoutingError, with: :not_found

  default_form_builder BootstrapForm::FormBuilder
  before_action :set_raven_context, :current_locale
  helper_method :current_organisation, :default_path
  before_action do
    Rack::MiniProfiler.authorize_request if current_user&.role_admin?
  end

  def default_url_options
    { org: current_organisation&.slug || params[:org], locale: current_locale }.merge(super)
  end

  protected

  def current_ability
    @current_ability ||= Ability::Base.new(current_user, current_organisation)
  end

  def responder_flash_messages(resource_name, scope: :update)
    {
      notice: t(:notice, scope: %i[flash actions] + [scope], resource_name: resource_name),
      error: t(:alert, scope: %i[flash actions] + [scope], resource_name: resource_name)
    }
  end

  def current_organisation
    nil
  end

  def current_locale
    return @current_locale if @current_locale.present?

    @current_locale = (I18n.available_locales & [params[:locale]&.to_sym, I18n.default_locale]).first
    I18n.locale = @current_locale
  end

  def default_path
    return manage_root_path if current_user&.role_manager?
    return organisation_path if current_organisation
    return new_user_session_path if current_user.blank?

    raise ActionController::RoutingError, 'Not found'
  end

  def set_raven_context
    return unless defined?(Raven)

    Raven.user_context(id: current_user&.email)
    Raven.extra_context(params: params.to_unsafe_h, url: request.url, organisation: current_organisation&.name)
  end

  def not_found
    render file: 'public/404.html', status: :not_found, layout: false
  end

  def unauthorized
    if current_user.nil?
      session[:next] = request.fullpath
      redirect_to new_user_session_path, alert: t('unauthorized')
    else
      redirect_back alert: t('unauthorized'), fallback_location: root_path
    end
  end
end
