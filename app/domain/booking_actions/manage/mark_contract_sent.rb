# frozen_string_literal: true

module BookingActions
  module Manage
    class MarkContractSent < BookingActions::Base
      templates << MailTemplate.define(:contract_sent_notification, context: %i[booking], autodeliver: false)

      def invoke!
        booking.contract.sent!
        mail = MailTemplate.use(:contract_sent_notification, booking, to: :tenant, &:save)

        Result.success redirect_proc: mail&.autodeliver_with_redirect_proc
      end

      def allowed?
        booking.contract.present? && !booking.contract&.sent?
      end
    end
  end
end
