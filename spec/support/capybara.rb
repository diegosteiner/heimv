# frozen_string_literal: true

require 'capybara-screenshot/rspec'
require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist
# Capybara.asset_host = 'http://localhost:3000'

Capybara::Paparazzi.config do |config|
  # config.screenshot_sizes = [ config.screenshot_sizes.first, (config.screenshot_sizes.last + [ :EXTRA_DATA ]) ]
  # config.file_dir = '../tmp/screenshots'
  # config.make_fewer_directories = true
  # config.make_shorter_filenames = true
  # config.path_and_suffix_generator = ->(shooter, url) {
  # shooter.path_and_suffix_for_url(url).collect{|p| p.split('/').last }
  # }
  # config.follow(:poltergeist)
end
