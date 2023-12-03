# frozen_string_literal: true

module BookingActions
  module Manage
    class MarkContractSent < BookingActions::Base
      templates << MailTemplate.define(:contract_sent_notification, context: %i[booking], autodeliver: false)

      def call!
        booking.contract.sent!
        mail = MailTemplate.use(:contract_sent_notification, booking, to: :tenant, &:save)

        Result.ok redirect_proc: mail && (!mail.autodeliver && proc { edit_manage_notification_path(mail) })
      end

      def allowed?
        booking.contract.present? && !booking.contract&.sent?
      end

      def booking
        context.fetch(:booking)
      end
    end
  end
end
