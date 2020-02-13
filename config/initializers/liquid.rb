module LiquidFilters
  def i18n_translate(input, scope = nil)
    I18n.t(input, scope: scope, default: nil)
  end

  def i18n_localize(input, format = :default)
    I18n.l(input, format: format.to_sym) if input.present?
  end

  def booking_purpose(input)
    i18n_translate(input, :'activerecord.enums.booking.purpose')
  end

  def currency(input)
    ::ActiveSupport::NumberHelper.number_to_currency(input)
  end
end

Liquid::Template.error_mode = :strict if Rails.env.development?
Liquid::Template.register_filter(LiquidFilters)
