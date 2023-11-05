# frozen_string_literal: true

module BookingActions
  module Manage
    class MarkContractSigned < BookingActions::Base
      RichTextTemplate.define(:contract_signed_notification, template_context: %i[booking], required_by: self)

      def call!
        booking.contract.signed!
        result = Result.new ok: booking.update(committed_request: true)

        return result unless Invoices::Deposit.of(booking).kept.unpaid.exists?

        booking.notifications.new(template: :contract_signed_notification, to: booking.tenant).deliver
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
