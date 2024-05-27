# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailContract < BookingActions::Base
      templates << MailTemplate.define(:awaiting_contract_notification, context: %i[booking contract],
                                                                        autodeliver: false)

      def invoke!
        mail = MailTemplate.use!(:awaiting_contract_notification, booking, to: :tenant, booking:, contract:,
                                                                           invoices: deposits)
        mail.attach :contract, deposits
        mail.save! && contract.sent! && deposits.each(&:sent!)

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

      # def offers
      #   @offers ||= booking.invoices.kept.unsent.where(type: [Invoices::Offer.to_s])
      # end

      def contract
        booking.contract
      end
    end
  end
end
