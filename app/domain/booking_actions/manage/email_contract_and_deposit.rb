# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailContractAndDeposit < BookingActions::Base
      MailTemplate.define(:awaiting_contract_notification, context: %i[booking contract])

      def call!
        notification = MailTemplate.use(:awaiting_contract_notification, to: :tenant, contract:, invoices:)
        notification.attach :contract, :contract_documents, invoices
        notification.save && contract.sent! && invoices.each(&:sent!)
        Result.new ok: notification.valid?, redirect_proc: redirect_proc(notification)
      end

      def allowed?
        booking.instance_exec do
          notifications_enabled && committed_request && contract.present? && !contract.sent? &&
            tenant.email.present? && Invoices::Deposit.of(self).kept.any?
        end
      end

      private

      def redirect_proc(notification)
        return unless notification&.persisted?

        proc do
          edit_manage_notification_path(notification)
        end
      end

      def invoices
        @invoices ||= booking.invoices.kept.unsent.where(type: [Invoices::Deposit.to_s, Invoices::Offer.to_s])
      end

      def contract
        booking.contract
      end

      def booking
        context.fetch(:booking)
      end
    end
  end
end
