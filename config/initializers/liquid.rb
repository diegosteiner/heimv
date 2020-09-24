# frozen_string_literal: true

Liquid::Template.error_mode = :strict if Rails.env.development?
Liquid::Template.register_filter(Module.new do
  def i18n_translate(value, scope = nil)
    I18n.t(value, scope: scope, default: nil)
  end

  def date_format(value, format = I18n.t('date.formats.default'))
    value = Date.iso8601(value) unless value.respond_to?(:strftime)
    value.strftime(format)
  rescue Date::Error
    nil
  end

  def datetime_format(value, format = I18n.t('time.formats.default'))
    value = DateTime.iso8601(value) unless value.respond_to?(:strftime)
    value.strftime(format)
  rescue Date::Error
    nil
  end

  def booking_purpose(value)
    i18n_translate(value, :'activerecord.enums.booking.purpose')
  end

  def currency(value)
    ::ActiveSupport::NumberHelper.number_to_currency(value)
  end
end)
