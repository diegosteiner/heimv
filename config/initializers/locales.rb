Rails.application.config do |config|
  config.i18n.available_locales = %w[de-CH en]
  config.i18n.default_locale = 'de-CH'
  config.i18n.fallbacks = { de: %i[de-CH en] }
end
