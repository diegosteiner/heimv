# frozen_string_literal: true

class Contract
  class Factory
    def call(booking, params = {})
      ::Contract.new(defaults(booking).merge(params)).tap do |contract|
        contract.text ||= rich_text_template(contract)
      end
    end

    def defaults(booking)
      { booking: booking }
    end

    def rich_text_template(contract)
      booking = contract.booking
      organisation = contract.organisation
      rich_text_template = organisation.rich_text_templates.enabled.by_key(:contract_text, home_id: booking.home_id)
      return if rich_text_template.blank?

      I18n.with_locale(booking.locale) do
        rich_text_template.interpolate booking: booking, home: booking.home,
                                       organisation: organisation, contract: contract,
                                       tarifs_table_placeholder: Export::Pdf::ContractPdf::TARIFS_TABLE_PLACEHOLDER
      end.body
    end
  end
end
