# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.7.2'

gem 'acts_as_list'
gem 'aws-sdk-s3', require: false
gem 'barnes'
gem 'blueprinter'
gem 'bootsnap'
gem 'bootstrap_form',
    git: 'https://github.com/bootstrap-ruby/bootstrap_form.git',
    ref: 'master'
gem 'camt_parser'
gem 'cancancan'
gem 'countries'
gem 'country_select'
gem 'dalli'
gem 'date_time_attribute'
gem 'devise'
gem 'devise-i18n'
gem 'discard'
gem 'factory_bot_rails', require: false
gem 'faker', require: false
gem 'icalendar'
gem 'kramdown'
gem 'liquid'
gem 'mobility'
gem 'pg'
gem 'pony'
gem 'prawn'
gem 'prawn-table'
gem 'puma'
gem 'rack-mini-profiler'
gem 'rails', '~> 6.1.0'
gem 'rails-i18n'
gem 'ranked-model'
gem 'react-rails'
gem 'responders'
gem 'rqrcode'
gem 'slim-rails'
gem 'statesman'
gem 'ttfunk', '~> 1.5.1' # See https://github.com/prawnpdf/prawn/issues/1142
gem 'webpacker', '>= 4.0.x'

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'foreman'
  gem 'i18n-tasks'
  gem 'i18n-tasks-csv'
  gem 'listen', '~> 3.0.5'
end

group :development, :test do
  gem 'brakeman'
  # gem 'bullet'
  gem 'bundler-audit'
  gem 'bundler-leak'
  gem 'byebug', platform: :mri
  gem 'database_cleaner'
  gem 'debase'
  gem 'dotenv-rails'
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'selenium-webdriver'
end

group :production do
  gem 'newrelic_rpm'
  gem 'sentry-raven'
end
