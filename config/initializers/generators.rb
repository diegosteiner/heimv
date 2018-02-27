Rails.application.config.generators do |g|
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
  g.scaffold_controller :responders_controller
end
