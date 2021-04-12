# frozen_string_literal: true

module PaymentInfos
  class TextPaymentInfo < ::PaymentInfo
    BookingFlow.require_rich_text_template(:text_payment_info_text, context: %i[payment_info])

    delegate :esr_beneficiary_account, to: :organisation

    def body
      @body ||= rich_text_template&.interpolate('payment_info' => self)
    end

    def title
      @title ||= rich_text_template&.title
    end

    def to_h
      super.merge(esr_beneficiary_account: esr_beneficiary_account, booking_ref: booking.ref)
    end

    protected

    def rich_text_template
      @rich_text_template ||= organisation.rich_text_templates.by_key(:text_payment_info_text)
    end
  end
end
