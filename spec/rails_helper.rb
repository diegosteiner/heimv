# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
require 'selenium/webdriver'
require 'capybara-screenshot/rspec'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false # DatabaseCleaner

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  # config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.before :suite do
    # Run webpack compilation before suite, so assets exists in public/packs
    # It would be better to run the webpack compilation only if at least one :js spec
    # should be executed, but `when_first_matching_example_defined`
    # does not work with `config.infer_spec_type_from_file_location!`
    # see https://github.com/rspec/rspec-core/issues/2366
    # `bin/webpack`
  end

  Capybara.register_driver :selenium do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_preference(:download, prompt_for_download: false,
                                      default_directory: '/tmp/downloads')

    options.add_preference(:browser, set_download_behavior: { behavior: 'allow' })
    # options.add_argument('--headless')
    # options.add_argument('--disable-gpu')
    # options.add_argument('--window-size=1280,1024')
    options.add_argument('--no-default-browser-check')
    options.add_argument('--start-maximized')

    # capabilities = Selenium::WebDriver::Remote::Capabilities.chrome('chromeOptions' => { 'args' => options })
    url = "http://#{ENV['SELENIUM_HOST']}:#{ENV['SELENIUM_PORT']}/wd/hub"
    Capybara::Selenium::Driver.new(app, browser: :chrome, url: url, options: options)
    # Capybara::Selenium::Driver.new(app, browser: :remote, url: url, desired_capabilities: capabilities)
  end

  if ENV['RAILS_PORT'].present?
    Capybara.run_server = true
    Capybara.server_port = ENV['RAILS_PORT']
    Capybara.server_host = '0.0.0.0'
  else
    Capybara.run_server = false
  end
  Capybara.default_driver = :selenium
  Capybara.default_max_wait_time = 10
  Capybara.app_host = "http://#{ENV['E2E_HOST'] || 'localhost'}"

  config.include Rails.application.routes.url_helpers
end
