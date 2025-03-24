# frozen_string_literal: true

module BookingActions
  class MarkContractSent < Base
    use_mail_template(:contract_sent_notification, context: %i[booking], autodeliver: false)

    def invoke!
      booking.contract.sent!
      mail = MailTemplate.use(:contract_sent_notification, booking, to: :tenant, &:save)

      Result.success redirect_proc: mail&.autodeliver_with_redirect_proc
    end

    def invokable?
      booking.contract.present? && !booking.contract&.sent?
    end
  end
end
