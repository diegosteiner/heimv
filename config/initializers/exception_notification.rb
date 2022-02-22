# frozen_string_literal: true

if defined?(ExceptionNotification)
  Rails.application.config.middleware.use ExceptionNotification::Rack,
                                          email: {
                                            email_prefix: "[#{ENV['APP_HOST']}] ",
                                            exception_recipients: ENV.fetch('EXCEPTION_RECIPIENTS',
                                                                            'info@heimv.ch').split(',')
                                          }
end

defined?(Sentry) && ENV['SENTRY_DSN'].present? && Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
end
