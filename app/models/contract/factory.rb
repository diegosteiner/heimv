# frozen_string_literal: true

class Contract
  class Factory
    def call(booking, params = {})
      ::Contract.new(defaults(booking).merge(params)).tap do |contract|
        I18n.with_locale(contract.locale) do
          contract.text ||= rich_text_template(contract)
        end
      end
    end

    def defaults(booking)
      { booking:, locale: booking.locale || I18n.locale }
    end

    protected

    def rich_text_template(contract)
      booking = contract.booking
      rich_text_template = contract.organisation.rich_text_templates
                                   .enabled.by_key(:contract_text)
      return if rich_text_template.blank?

      I18n.with_locale(booking.locale) { rich_text_template.interpolate(template_context(contract)) }.body
    end

    def template_context(contract)
      booking = contract.booking
      TemplateContext.new(
        booking:, organisation: booking.organisation, contract:,
        costs: CostEstimation.new(booking)
      )
    end
  end
end
