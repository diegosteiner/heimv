# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailOffers < BookingActions::Base
      RichTextTemplate.require_template(:offer_notification, template_context: %i[booking invoices], required_by: self)

      def call!
        notification = prepare_notification
        notification.deliver && offers.each(&:sent!)
      end

      def allowed?
        offers.any? && booking.notifications_enabled && booking.tenant.email.present?
      end

      protected

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
