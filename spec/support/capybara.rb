# frozen_string_literal: true

require 'capybara-screenshot/rspec'
require 'capybara/rspec'

Capybara.asset_host = 'http://localhost:3000'
Capybara.javascript_driver = :webkit
