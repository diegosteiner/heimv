# frozen_string_literal: true

require_relative 'boot'

require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_mailer/railtie'
require 'active_job/railtie'
# require 'action_cable/engine'
# require 'rails/test_unit/railtie'
# require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Heimverwaltung
  class Application < Rails::Application
    # Use the responders controller from the responders gem
    config.app_generators.scaffold_controller :responders_controller

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    config.generators do |g|
      g.test_framework :rspec,
                       fixtures: true,
                       view_specs: true,
                       helper_specs: true,
                       routing_specs: false,
                       controller_specs: false,
                       request_specs: false
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
      g.stylesheets     false
      g.javascripts     false
      g.helpers false
      g.assets false
      g.system_tests false
    end

    # config.assets.enabled = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.i18n.available_locales = %w[de-CH en]
    config.i18n.default_locale = 'de-CH'
    config.i18n.fallbacks = { de: %i[de-CH en] }

    Rails.application.routes.default_url_options[:host] = Rails.application.secrets.app_host
  end
end
