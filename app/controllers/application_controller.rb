# frozen_string_literal: true

class ApplicationController < ActionController::Base
  responders :flash, :http_cache
  respond_to :html, :json

  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied, with: :unauthorized
  rescue_from ActionController::InvalidAuthenticityToken, with: :invalid_request
  rescue_from ActionDispatch::Http::Parameters::ParseError, with: :invalid_request
  rescue_from ActiveRecord::RecordNotFound, ActionController::RoutingError, with: :not_found

  default_form_builder BootstrapForm::FormBuilder
  before_action :prepare_exception_notification_context, :current_locale, :set_default_meta_tags
  helper_method :current_organisation, :current_organisation_user, :home_path
  before_action do
    Rack::MiniProfiler.authorize_request if current_user&.role_admin?
  end

  def default_url_options
    { org: current_organisation&.to_param || params[:org], locale: current_locale }.merge(super)
  end

  def set_default_meta_tags
    set_meta_tags({
                    site: t('titles.application', organisation: current_organisation&.name),
                    reverse: true,
                    separator: '&middot;'.html_safe,
                    noindex: true,
                    nofollow: true
                  })
  end

  protected

  def current_ability
    @current_ability ||= Ability::Base.new(current_user, current_organisation)
  end

  def responder_flash_messages(resource_name, scope: :update)
    {
      notice: t(:notice, scope: %i[flash actions] + [scope], resource_name:),
      error: t(:alert, scope: %i[flash actions] + [scope], resource_name:)
    }
  end

  def current_organisation
    Organisation.find_by(slug: params[:org].presence)
  end

  def current_locale
    return @current_locale if @current_locale.present?

    requested_locale = params[:locale]&.to_sym
    @current_locale = I18n.available_locales.include?(requested_locale) ? requested_locale : I18n.default_locale
    I18n.locale = @current_locale
  end

  def current_organisation_user
    @current_organisation_user ||= current_user&.in_organisation(current_organisation)
  end

  def home_path
    if current_organisation
      return manage_root_path if current_organisation_user&.role?(:admin, :manager, :readonly)

      return organisation_path
    end
    if current_user
      return url_for(org: current_user.default_organisation) if current_user.default_organisation

      return root_path
    end

    new_user_session_path
  end

  def prepare_exception_notification_context
    request.env['exception_notifier.exception_data'] = {
      email: current_user&.email,
      params: params.to_unsafe_h,
      url: request.url,
      organisation: current_organisation&.name
    }
  end

  def not_found
    render file: 'public/404.html', status: :not_found, layout: false
  end

  def unauthorized
    if current_user.nil?
      redirect_to new_user_session_path(return_to: request.fullpath), alert: t('unauthorized')
    else
      redirect_back alert: t('unauthorized'), fallback_location: -> { root_path }
    end
  end

  def invalid_request
    redirect_back alert: t('errors.invalid_csrf_token'), fallback_location: -> { root_path }
  end

  def return_to_path(default = nil)
    params[:return_to].presence || default || home_path
  end

  def after_sign_in_path_for(_resource)
    return_to_path
  end

  def require_user!
    raise CanCan::AccessDenied if current_user.blank?
  end

  def require_organisation!
    return if current_organisation
    return redirect_to home_path if current_user&.default_organisation
    return unauthorized if current_user.blank?

    raise ActionController::RoutingError, 'Not found'
  end
end
