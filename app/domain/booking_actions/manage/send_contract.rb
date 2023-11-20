# frozen_string_literal: true

module BookingActions
  module Manage
    class SendContract < BookingActions::Base
      # MailTemplate.define(:awaiting_contract_notification, context: %i[booking contract])

      def call!
        mail = MailTemplate.use!(:awaiting_contract_notification, booking, to: :tenant, contract:, invoices:)
        mail.attach :contract, :contract_documents, invoices
        mail.save! && contract.sent! && invoices.each(&:sent!)

        Result.new ok: true, redirect_proc: proc { edit_manage_notification_path(mail) }
      end

      def allowed?
        booking.instance_exec do
          valid? && committed_request && contract.present? && !contract.sent?
        end
      end

      private

      def mode
        return :mark_sent if booking.email.blank?
        return :email_contract_without_deposit if deposits.none?

        :email_contract_and_deposit
      end

      def deposits
        @deposits ||= booking.invoices.kept.unsent.where(type: [Invoices::Deposit.to_s])
      end

      def offers
        @offers ||= booking.invoices.kept.unsent.where(type: [Invoices::Offer.to_s])
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
