# frozen_string_literal: true

require 'i18n/backend/fallbacks'

I18n.available_locales = %w[de fr it en]
I18n.default_locale = :de
I18n::Backend::Simple.include I18n::Backend::Fallbacks
Faker::Config.locale = :de if defined?(Faker)

ISO3166.configure do |config|
  config.locales = %i[de fr it]
end

CountrySelect::FORMATS[:default] = lambda do |country|
  country.translations[I18n.locale.to_s.split('-')[0]] || country.name
end
