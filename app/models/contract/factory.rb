# frozen_string_literal: true

class Contract
  class Factory
    def call(booking, params = {})
      ::Contract.new(defaults(booking).merge(params)).tap do |contract|
        I18n.with_locale(contract.locale) do
          contract.text ||= rich_text_template_body(contract)
        end
      end
    end

    def defaults(booking)
      { booking:, locale: booking.locale || I18n.locale }
    end

    protected

    def rich_text_template_body(contract)
      context = { booking: contract.booking, organisation: contract.booking.organisation,
                  contract:, costs: CostEstimation.new(contract.booking) }
      contract.organisation.rich_text_templates.enabled.by_key(:contract_text)
              &.interpolate(context, locale: contract.locale)
              &.body
    end
  end
end
