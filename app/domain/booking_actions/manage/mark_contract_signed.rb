# frozen_string_literal: true

module BookingActions
  module Manage
    class MarkContractSigned < BookingActions::Base
      RichTextTemplate.require_template(:contract_signed_notification, context: %i[booking], required_by: self)

      def call!
        booking.contract.signed!
        booking.update(committed_request: true)

        return unless Invoices::Deposit.of(booking).kept.unpaid.exists?

        booking.notifications.new(template: :contract_signed_notification, to: booking.tenant).deliver
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
