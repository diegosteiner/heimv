# frozen_string_literal: true

module BookingActions
  module Manage
    class MarkContractSigned < BookingActions::Base
      MailTemplate.define(:contract_signed_notification, context: %i[booking])

      def call!
        booking.contract.signed!
        result = Result.new ok: booking.update(committed_request: true)

        return result unless Invoices::Deposit.of(booking).kept.unpaid.exists?

        MailTemplate.use(:contract_signed_notification, booking, to: :tenant, &:deliver)
        result
      end

      def allowed?
        booking.contract&.sent? && !booking.contract&.signed?
      end

      def booking
        context.fetch(:booking)
      end
    end
  end
end
