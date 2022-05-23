# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailContractAndDeposit < BookingActions::Base
      RichTextTemplate.require_template(:awaiting_contract_notification, context: %i[booking], required_by: self)

      def call!(contract = booking.contract, deposits = Invoices::Deposit.of(booking).kept.unsent)
        notification = booking.notifications.new(template: :awaiting_contract_notification, to: booking.tenant)
        notification.attach(prepare_attachments(booking, deposits, contract).map(&:blob))
        notification.save! && contract.sent! && deposits.each(&:sent!) && notification.deliver
      end

      def allowed?
        booking.contract.present? && !booking.contract.sent? &&
          booking.tenant.email.present? && booking.committed_request
      end

      def prepare_attachments(booking, deposits, contract)
        [
          DesignatedDocument.in_context(booking).with_locale(booking.locale).where(send_with_contract: true),
          deposits.map(&:pdf),
          contract.pdf
        ].flatten.compact
      end

      def booking
        context.fetch(:booking)
      end
    end
  end
end
