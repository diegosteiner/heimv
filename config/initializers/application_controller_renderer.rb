# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# ActiveSupport::Reloader.to_prepare do
#   ApplicationController.renderer.defaults.merge!(
#     http_host: 'example.org',
#     https: false
#   )
# end

Rails.application.routes.default_url_options[:host] = (Rails.env.test? &&
                                                      ENV['E2E_TARGET_HOST']) ||
                                                      ENV.fetch('APP_HOST')
