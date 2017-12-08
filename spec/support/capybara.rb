# frozen_string_literal: true

require 'capybara-screenshot/rspec'
require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist
Capybara.asset_host = 'http://localhost:3000'
