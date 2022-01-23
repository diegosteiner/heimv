# frozen_string_literal: true

module LocaleEnumerable
  extend ActiveSupport::Concern

  included do
    enum locale: I18n.available_locales.index_by(&:to_sym).transform_values(&:to_s),
         _prefix: true, _default: I18n.locale || I18n.default_locale
  end
end
