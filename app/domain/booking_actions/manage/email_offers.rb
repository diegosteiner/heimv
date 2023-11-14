# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailOffers < BookingActions::Base
      MailTemplate.define(:offer_notification, context: %i[booking invoices], optional: true)

      def call!
        mail = MailTemplate.use(:offer_notification, booking, to: booking.tenant, attach: offers, invoices: offers)
        mail.save && offers.each(&:sent!)

        Result.new ok: mail.valid?, redirect_proc: redirect_proc(mail)
      end

      def allowed?
        offers.any? && booking.notifications_enabled && booking.tenant.email.present? &&
          MailTemplate.where(key: :offer_notification, enabled: true)
      end

      protected

      def redirect_proc(notification)
        return unless notification&.persisted?

        proc do
          edit_manage_notification_path(notification)
        end
      end

      def booking
        context.fetch(:booking)
      end

      def offers
        context[:offers].presence || booking.invoices.where(type: Invoices::Offer.to_s).unsent
      end
    end
  end
end
