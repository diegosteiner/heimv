# frozen_string_literal: true

return if ENV.fetch('SENTRY_DSN', '').blank?

Sentry.init do |config|
  config.dsn = ENV.fetch('SENTRY_DSN')
  config.environment = Rails.env
  config.release = Rails.root.join('VERSION').read.strip
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
  config.send_default_pii = false
  config.traces_sample_rate = 0.1
  config.profiles_sample_rate = 0.0
  config.excluded_exceptions += %w[
    ActiveRecord::RecordNotFound
    ActionController::RoutingError
    ActionController::InvalidAuthenticityToken
    ActionDispatch::Http::Parameters::ParseError
    CanCan::AccessDenied
  ]
end
