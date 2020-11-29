# frozen_string_literal: true

module PaymentInfos
  class ForeignPaymentInfo < TextPaymentInfo
    BookingStrategy.require_markdown_template(:foreign_payment_info_text, context: %i[payment_info])

    protected

    def markdown_template
      @markdown_template ||= organisation.markdown_templates.by_key(:foreign_payment_info_text)
    end
  end
end
