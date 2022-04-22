# frozen_string_literal: true

module PaymentInfos
  class ForeignPaymentInfo < TextPaymentInfo
    ::PaymentInfo.register_subtype self
    RichTextTemplate.require_template(:foreign_payment_info_text, context: %i[payment_info], required_by: self)

    protected

    def rich_text_template
      @rich_text_template ||= organisation.rich_text_templates.enabled.by_key(:foreign_payment_info_text)
    end
  end
end
