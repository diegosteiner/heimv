# frozen_string_literal: true

Capybara.register_driver :selenium_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_preference(:browser, set_download_behavior: { behavior: 'allow' })
  options.add_preference(:download, prompt_for_download: false, default_directory: '/tmp/downloads')

  options.add_argument('--headless=new') if ENV['SELENIUM_VNC'].blank?
  options.add_argument('--window-size=1280,1024')
  options.add_argument('--no-default-browser-check')
  options.add_argument('--disable-search-engine-choice-screen')
  # see https://github.com/teamcapybara/capybara/issues/2800
  # options.add_argument('--disable-backgrounding-occluded-windows')
  # options.add_argument('--no-sandbox')

  Capybara::Selenium::Driver.new(app, browser: :remote, capabilities: [options],
                                      url: "http://#{ENV.fetch('SELENIUM_HOST', nil)}/wd/hub")
end

Capybara.run_server = ENV['E2E_SERVER_PORT'].present?
Capybara.server_port = ENV.fetch('E2E_SERVER_PORT', nil)
Capybara.server_host = '0.0.0.0'
Capybara.app_host = "http://#{ENV.fetch('E2E_TARGET_HOST', nil)}" if ENV['E2E_TARGET_HOST'].present?
Capybara.default_driver = :selenium_chrome
Capybara.default_max_wait_time = 10
