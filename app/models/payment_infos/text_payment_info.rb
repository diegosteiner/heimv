module PaymentInfos
  class TextPaymentInfo < ::PaymentInfo
    delegate :esr_participant_nr, to: :organisation

    def body
      @body ||= markdown_template.interpolate('payment_info' => self)
    end

    def title
      @title ||= markdown_template.title
    end

    def to_h
      super.merge(esr_participant_nr: esr_participant_nr, booking_ref: booking.ref)
    end

    protected

    def markdown_template
      @markdown_template ||= MarkdownTemplate[:text_payment_info_text]
    end
  end
end
