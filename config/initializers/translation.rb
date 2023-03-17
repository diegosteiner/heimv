# frozen_string_literal: true

if ENV['TRANSLATION_IO_API_KEY'].present?
  TranslationIO.configure do |config|
    config.api_key = ENV.fetch('TRANSLATION_IO_API_KEY')
    config.source_locale = :de
    config.target_locales = %i[fr it]
    config.disable_gettext = true
    config.charset = 'UTF-8'
  end
end
