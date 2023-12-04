# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailOffers < BookingActions::Base
      templates << MailTemplate.define(:offer_notification, context: %i[booking invoices], optional: true,
                                                            autodeliver: false)

      def call!
        mail = MailTemplate.use!(:offer_notification, booking, to: booking.tenant, attach: offers, invoices: offers)
        mail.save! && offers.each(&:sent!)

        Result.ok redirect_proc: !mail.autodeliver && proc { edit_manage_notification_path(mail) }
      end

      def allowed?
        offers.any? && booking.notifications_enabled && booking.email.present? &&
          MailTemplate.exists?(key: :offer_notification, enabled: true)
      end

      protected

      def booking
        context.fetch(:booking)
      end

      def offers
        context[:offers].presence || booking.invoices.where(type: Invoices::Offer.to_s).unsent
      end
    end
  end
end
