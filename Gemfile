# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.5.0'

gem 'bootsnap'
gem 'bootstrap_form',
    git: 'https://github.com/bootstrap-ruby/bootstrap_form.git',
    ref: 'master'
gem 'breadcrumbs'
gem 'cancancan'
gem 'devise'
gem 'devise-i18n'
gem 'factory_bot_rails', require: false
gem 'faker', require: false
gem 'kramdown'
gem 'pg'
gem 'puma', '~> 3.0'
gem 'rails', '>= 5.2.0.beta'
gem 'rails-i18n', '~> 5.0.0'
gem 'responders'
gem 'slim-rails'
gem 'statesman'
gem 'title'
gem 'webpacker'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'foreman'
  gem 'i18n-tasks'
  gem 'letter_opener'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development, :test do
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'byebug', platform: :mri
  gem 'dotenv-rails'
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'rspec-rails'
  gem 'rubocop'
end

group :test do
  gem 'capybara'
  gem 'capybara-paparazzi'
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'poltergeist'
end
