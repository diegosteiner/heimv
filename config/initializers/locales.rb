# frozen_string_literal: true

I18n.available_locales = %w[de fr it en]
I18n.default_locale = :de
Faker::Config.locale = :de if defined?(Faker)

ISO3166.configure do |config|
  config.locales = %i[de fr it]
end

CountrySelect::FORMATS[:default] = lambda do |country|
  country.translations[I18n.locale.to_s.split('-')[0]] || country.name
end
