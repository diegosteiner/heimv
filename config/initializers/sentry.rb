# frozen_string_literal: true

defined?(Sentry) && ENV['SENTRY_DSN'].present? && Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
end
