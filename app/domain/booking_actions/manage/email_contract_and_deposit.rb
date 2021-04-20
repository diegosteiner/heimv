# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailContractAndDeposit < BookingActions::Base
      RichTextTemplate.require_template(:awaiting_contract_notification, %i[booking], self)

      def call!(contract = booking.contract, deposits = Invoices::Deposit.of(booking).kept.unpaid.unsent)
        notification = booking.notifications.new(from_template: :awaiting_contract_notification,
                                                 addressed_to: :tenant)
        notification.attachments.attach(extract_attachments(booking.home, deposits, contract))
        notification.save! && contract.sent! && deposits.each(&:sent!) && notification.deliver
      end

      def allowed?
        booking.contract.present? && !booking.contract.sent? && booking.tenant.email.present?
      end

      def extract_attachments(home, deposits, contract)
        [
          home.house_rules.attachment&.blob,
          deposits.map { |deposit| deposit.pdf.blob },
          contract.pdf&.blob
        ].flatten.compact
      end

      def booking
        context.fetch(:booking)
      end
    end
  end
end
