# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailOffers < BookingActions::Base
      templates << MailTemplate.define(:offer_notification, context: %i[booking invoices], optional: true,
                                                            autodeliver: false)

      def invoke!(offer_ids: nil)
        offers = offer_ids.present? ? booking.organisation.invoices : unsent_offers.where(id: offer_ids)
        mail = prepare_mail(offers)
        mail.save! && offers.each(&:sent!)

        Result.success redirect_proc: mail&.autodeliver_with_redirect_proc
      end

      def allowed?
        unsent_offers.any? && booking.notifications_enabled && booking.email.present? &&
          MailTemplate.exists?(key: :offer_notification, enabled: true)
      end

      protected

      def prepare_mail(offers)
        mail = MailTemplate.use!(:offer_notification, booking, to: booking.tenant, invoices: offers)
        mail.attach(offers)
        mail
      end

      def unsent_offers
        booking.invoices.where(type: Invoices::Offer.to_s).unsent
      end
    end
  end
end
