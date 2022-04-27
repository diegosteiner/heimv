# frozen_string_literal: true

Capybara.register_driver :selenium do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_preference(:browser, set_download_behavior: { behavior: 'allow' })
  options.add_preference(:download, prompt_for_download: false,
                                    default_directory: '/tmp/downloads')

  options.add_argument('--headless')
  options.add_argument('--window-size=1280,1024')
  options.add_argument('--no-default-browser-check')
  options.add_argument('--start-maximized')

  url = "http://#{ENV.fetch('SELENIUM_HOST', nil)}/wd/hub"
  Capybara::Selenium::Driver.new(app, browser: :chrome, url: url, capabilities: [options])
end

Capybara.run_server = ENV['E2E_SERVER_PORT'].present?
Capybara.server_port = ENV.fetch('E2E_SERVER_PORT', nil)
Capybara.server_host = '0.0.0.0'
Capybara.app_host = "http://#{ENV.fetch('E2E_TARGET_HOST', nil)}" if ENV['E2E_TARGET_HOST'].present?
# Selenium::WebDriver.logger.level = :debug
Capybara.default_driver = :selenium
Capybara.default_max_wait_time = 10
