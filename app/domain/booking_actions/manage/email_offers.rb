# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailOffers < BookingActions::Base
      templates << MailTemplate.define(:offer_notification, context: %i[booking invoices], optional: true,
                                                            autodeliver: false)

      def invoke!(offer_ids: nil)
        offers = offer_ids.present? ? booking.organisation.invoices.where(id: offer_ids) : unsent_offers
        mail = send_tenant_notification(offers)

        Result.success redirect_proc: mail&.autodeliver_with_redirect_proc
      end

      def allowed?
        unsent_offers.any? && booking.notifications_enabled && booking.email.present? &&
          MailTemplate.exists?(key: :offer_notification, enabled: true)
      end

      protected

      def send_tenant_notification(offers)
        context = { invoices: offers }
        MailTemplate.use!(:offer_notification, booking, to: :tenant, context:).tap do |mail|
          mail.attach(offers)
          mail.save! && offers.each(&:sent!)
        end
      end

      def unsent_offers
        booking.invoices.where(type: Invoices::Offer.to_s).unsent
      end
    end
  end
end
