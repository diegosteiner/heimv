# frozen_string_literal: true

module BookingActions
  module Manage
    class MarkContractSigned < BookingActions::Base
      RichTextTemplate.require_template(:contract_signed_notification, context: %i[booking], required_by: self)

      def call!
        if Invoices::Deposit.of(booking).kept.unpaid.exists?
          booking.notifications.new(template: :contract_signed_notification, to: booking.tenant).deliver
        end

        booking.contract.signed!
        booking.auto_transition
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
