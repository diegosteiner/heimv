# frozen_string_literal: true

module BookingActions
  module Manage
    class MarkContractSigned < BookingActions::Base
      templates << MailTemplate.define(:contract_signed_notification, context: %i[booking], autodeliver: false)

      def invoke!
        booking.contract.signed!
        booking.update(committed_request: true)

        return Result.success unless deposits.exists?

        mail = MailTemplate.use(:contract_signed_notification, booking, to: :tenant)
        Result.success redirect_proc: mail && (!mail.autodeliver && proc { edit_manage_notification_path(mail) })
      end

      def allowed?
        booking.contract&.sent? && !booking.contract&.signed?
      end

      def booking
        context.fetch(:booking)
      end

      protected

      def deposits
        Invoices::Deposit.of(booking).kept.unpaid
      end
    end
  end
end
