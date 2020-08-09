# frozen_string_literal: true

module PaymentInfos
  class ForeignPaymentInfo < TextPaymentInfo
    protected

    def markdown_template
      @markdown_template ||= organisation.markdown_templates.by_key(:foreign_payment_info_text)
    end
  end
end
