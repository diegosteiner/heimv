# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailContractAndDeposit < BookingActions::Base
      RichTextTemplate.require_template(:awaiting_contract_notification, context: %i[booking], required_by: self)

      def call!(contract = booking.contract, deposits = Invoices::Deposit.of(booking).kept.unpaid.unsent)
        notification = booking.notifications.new(from_template: :awaiting_contract_notification,
                                                 to: booking.tenant)
        notification.attachments.attach(attachments_for(booking.home, deposits, contract))
        notification.save! && contract.sent! && deposits.each(&:sent!) && notification.deliver
      end

      def allowed?
        booking.contract.present? && !booking.contract.sent? && booking.tenant.email.present?
      end

      def attachments_for(home, deposits, contract)
        [
          home.designated_documents.localized(:house_rules, locale: booking.locale)&.file&.blob,
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
