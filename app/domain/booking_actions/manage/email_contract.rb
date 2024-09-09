# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailContract < BookingActions::Base
      templates << MailTemplate.define(:awaiting_contract_notification, context: %i[booking contract],
                                                                        autodeliver: false)
      templates << MailTemplate.define(:operator_contract_sent_notification, context: %i[booking contract],
                                                                             optional: true)

      def invoke!
        mail = send_tenant_notification(deposits)
        send_operator_notification(deposits) if mail.persisted? && deposits.present?

        Result.success redirect_proc: mail&.autodeliver_with_redirect_proc
      end

      def allowed?
        booking.instance_exec do
          valid? && notifications_enabled && contract.present? && !contract.sent? && email.present?
        end
      end

      def label
        translate(deposits.present? ? :label_with_deposit : :label_without_deposit)
      end

      def confirm
        translate(:confirm) if deposits.blank?
      end

      protected

      def deposits
        @deposits ||= booking.invoices.kept.unsent.where(type: [Invoices::Deposit.to_s])
      end

      def send_tenant_notification(deposits)
        context = { contract:, invoices: deposits }
        MailTemplate.use!(:awaiting_contract_notification, booking, to: :tenant, context:) do |mail|
          mail.attach :contract, deposits
          mail.save! && contract.sent! && deposits.each(&:sent!)
        end
      end

      def send_operator_notification(deposits)
        context = { contract:, invoices: deposits }
        MailTemplate.use(:operator_contract_sent_notification, booking, to: :billing, context:)&.tap do |mail|
          mail.attach contract, deposits
          mail.autodeliver!
        end
      end

      def contract
        booking.contract
      end
    end
  end
end
