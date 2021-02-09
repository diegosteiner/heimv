# frozen_string_literal: true

module PaymentInfos
  class TextPaymentInfo < ::PaymentInfo
    BookingStrategy.require_markdown_template(:text_payment_info_text, context: %i[payment_info])

    delegate :esr_beneficiary_account, to: :organisation

    def body
      @body ||= markdown_template&.interpolate('payment_info' => self)
    end

    def title
      @title ||= markdown_template&.title
    end

    def to_h
      super.merge(esr_beneficiary_account: esr_beneficiary_account, booking_ref: booking.ref)
    end

    protected

    def markdown_template
      @markdown_template ||= organisation.markdown_templates.by_key(:text_payment_info_text)
    end
  end
end
