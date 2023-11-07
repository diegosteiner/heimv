# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailOffers < BookingActions::Base
      MailTemplate.define(:offer_notification, context: %i[booking invoices], optional: true)

      def call!
        notification = prepare_notification
        notification.save! && offers.each(&:sent!)

        Result.new ok: notification.valid?, redirect_proc: redirect_proc(notification)
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

      def prepare_notification
        booking.notifications.new(template: :offer_notification, to: booking.tenant,
                                  template_context: { invoices: offers }) do |notification|
          notification.attach(prepare_attachments)
        end
      end

      def prepare_attachments
        offers.with_default_includes.includes([:pdf_blob, { pdf_attachment: [:blob] }])
              .map { |invoice| invoice.pdf.blob }
      end
    end
  end
end
