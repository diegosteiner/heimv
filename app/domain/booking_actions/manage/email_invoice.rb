# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailInvoice < BookingActions::Base
      RichTextTemplate.require_template(:payment_due_notification, context: %i[booking], required_by: self)

      def call!(invoices = booking.invoices.unsent)
        notification = booking.notifications.new(from_template: :payment_due_notification, addressed_to: :tenant)
        return unless notification

        pdfs = invoices.with_default_includes
                       .includes([:pdf_blob, { pdf_attachment: [:blob] }])
                       .map { |invoice| invoice.pdf.blob }
        notification.attachments.attach(pdfs)
        notification.deliver && invoices.each(&:sent!)
      end

      def allowed?
        booking.invoices.unsent.any? &&
          !booking.booking_flow.in_state?(:definitive_request) &&
          booking.tenant.email.present?
      end

      def booking
        context.fetch(:booking)
      end
    end
  end
end
