Rails.application.config.i18n.fallbacks = { de: %i[de-ch en] }
I18n.available_locales = %w[de en]
I18n.default_locale = :de

ISO3166.configure do |config|
  config.locales = %i[de fr it]
end

CountrySelect::FORMATS[:default] = lambda do |country|
  country.translations[I18n.locale.to_s.split('-')[0]] || country.name
end
