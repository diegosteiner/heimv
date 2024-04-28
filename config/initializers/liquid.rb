# frozen_string_literal: true

Liquid::Template.error_mode = :strict unless Rails.env.production?
Liquid::Template.register_filter(Module.new do
  def i18n_translate(value, scope = nil)
    I18n.t(value, scope:, default: nil)
  end

  def date_format(value, format = I18n.t('date.formats.default'))
    value = Date.iso8601(value) unless value.respond_to?(:strftime)
    I18n.l(value, format:)
  rescue Date::Error, TypeError
    nil
  end

  def datetime_format(value, format = I18n.t('time.formats.default'))
    value = DateTime.iso8601(value) unless value.respond_to?(:strftime)
    I18n.l(value, format:)
  rescue Date::Error, TypeError
    nil
  end

  def currency(value, unit = nil)
    return ActiveSupport::NumberHelper.number_to_currency(value, unit:) if unit.present?

    ActiveSupport::NumberHelper.number_to_currency(value)
  end

  def as_liquid(value)
    "{{ #{value} }}"
  end

  def booking_condition(value, type, *args)
    # compare_value = args.pop
    # compare_operator = args.pop
    # compare_attribute = args.pop
    # booking_condition = BookingConditions.const_get(type)&.new(compare_attribute:, compare_operator:, compare_value:)
    # booking_condition&.evaluate(Booking.find(value.fetch('id')))
  end
end)
