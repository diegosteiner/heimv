# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailContractWithoutDeposit < EmailContractAndDeposit
      def call!(contract = booking.contract)
        mail = MailTemplate.use(:awaiting_contract_notification, booking,
                                to: booking.tenant, contract:, attach: [contract, :contract_documents])
        mail.save && contract.sent!
        Result.new ok: mail.valid?, redirect_proc: redirect_proc(mail)
      end

      def allowed?
        booking.instance_exec do
          notifications_enabled && committed_request && contract.present? && !contract.sent? &&
            tenant.email.present? && Invoices::Deposit.of(self).kept.none?
        end
      end

      def button_options
        super.merge(
          data: {
            confirm: translate(:confirm)
          }
        )
      end

      private

      def redirect_proc(notification)
        return unless notification&.persisted?

        proc do
          edit_manage_notification_path(notification)
        end
      end

      def booking
        context.fetch(:booking)
      end
    end
  end
end
