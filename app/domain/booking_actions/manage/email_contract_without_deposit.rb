# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailContractWithoutDeposit < EmailContractAndDeposit
      RichTextTemplate.require_template(:awaiting_contract_notification, context: %i[booking], required_by: self)

      def call!(contract = booking.contract)
        notification = booking.notifications.new(template: :awaiting_contract_notification, to: booking.tenant)
        notification.attach(prepare_attachments(booking, contract).map(&:blob))
        notification.save! && contract.sent! && notification.deliver
      end

      def allowed?
        booking.contract.present? && !booking.contract.sent? && Invoices::Deposit.of(booking).kept.none? &&
          booking.tenant.email.present? && booking.committed_request
      end

      def button_options
        super.merge(
          data: {
            confirm: translate(:confirm)
          }
        )
      end

      private

      def prepare_attachments(booking, contract)
        [
          DesignatedDocument.in_context(booking).with_locale(booking.locale).where(send_with_contract: true),
          contract.pdf
        ].flatten.compact
      end

      def booking
        context.fetch(:booking)
      end
    end
  end
end
