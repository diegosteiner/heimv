# frozen_string_literal: true

module PaymentInfos
  class Refund < ::PaymentInfo
    ::PaymentInfo.register_subtype self

    use_template(:refund_payment_info_text, context: %i[payment_info invoice])

    def body
      @body ||= rich_text_template&.interpolate({ payment_info: self, invoice: })&.body
    end

    def title
      @title ||= rich_text_template&.title
    end

    protected

    def rich_text_template
      @rich_text_template ||= organisation.rich_text_templates.enabled.by_key(:refund_payment_info_text)
    end
  end
end
