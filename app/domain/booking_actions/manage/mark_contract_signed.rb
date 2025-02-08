# frozen_string_literal: true

module BookingActions
  module Manage
    class MarkContractSigned < BookingActions::Public::SignContract
      # templates << MailTemplate.define(:contract_signed_notification, context: %i[booking], autodeliver: false)

      def invoke!(signed_pdf: nil, **)
        booking.contract.update(signed_pdf:) if signed_pdf.present?
        booking.contract.signed!
        booking.update(committed_request: true)

        return Result.success unless deposits.exists?

        mail = MailTemplate.use(:contract_signed_notification, booking, to: :tenant)
        Result.success redirect_proc: mail&.autodeliver_with_redirect_proc
      end

      def allowed?
        booking.contract&.sent? && !booking.contract&.signed?
      end
    end
  end
end
