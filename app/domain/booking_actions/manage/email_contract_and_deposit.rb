# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailContractAndDeposit < BookingActions::Base
      RichTextTemplate.require_template(:awaiting_contract_notification, context: %i[booking], required_by: self)

      def call!
        notification = booking.notifications.new(template: :awaiting_contract_notification, to: booking.tenant)
        notification.attach(prepare_attachments.map(&:blob))
        notification.save! && contract.sent! && invoices.each(&:sent!) && notification.deliver
      end

      def allowed?
        booking.instance_exec do
          notifications_enabled && committed_request && contract.present? && !contract.sent? &&
            tenant.email.present? && Invoices::Deposit.of(self).kept.any?
        end
      end

      private

      def invoices
        @invoices ||= booking.invoices.kept.unsent.where(type: [Invoices::Deposit.to_s, Invoices::Offer.to_s])
      end

      def contract
        booking.contract
      end

      def prepare_attachments
        [
          DesignatedDocument.for_booking(booking).where(send_with_contract: true),
          invoices.map(&:pdf),
          contract.pdf
        ].flatten.compact
      end

      def booking
        context.fetch(:booking)
      end
    end
  end
end
