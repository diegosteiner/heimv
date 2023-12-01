# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailContract < BookingActions::Base
      templates << MailTemplate.define(:awaiting_contract_notification, context: %i[booking contract],
                                                                        autodeliver: false)

      def call!
        mail = MailTemplate.use!(:awaiting_contract_notification, booking, to: :tenant, contract:, invoices: deposits)
        mail.attach :contract, :contract_documents, deposits
        mail.save! && contract.sent! && deposits.each(&:sent!)

        Result.ok redirect_proc: !mail.autodeliver && proc { edit_manage_notification_path(mail) }
      end

      def allowed?
        booking.instance_exec do
          valid? && notifications_enabled && contract.present? && !contract.sent? && email.present?
        end
      end

      def label
        translate(deposits.present? ? :label_with_deposit : :label_without_deposit)
      end

      def button_options
        return super if deposits.present?

        super.merge(data: { confirm: translate(:confirm) })
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

      def booking
        context.fetch(:booking)
      end
    end
  end
end
