# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailInvoice < BookingActions::Base
      RichTextTemplate.require_template(:payment_due_notification, template_context: %i[booking], required_by: self)

      def call!(invoices = booking.invoices.unsent)
        notification = booking.notifications.new(template: :payment_due_notification, to: booking.tenant,
                                                 template_context: { invoices: invoices })
        return unless notification

        pdfs = invoices.with_default_includes
                       .includes([:pdf_blob, { pdf_attachment: [:blob] }])
                       .map { |invoice| invoice.pdf.blob }
        notification.attach(pdfs)
        notification.deliver && invoices.each(&:sent!)
      end

      def allowed?
        booking.instance_exec do
          notifications_enabled && invoices.unsent.any? &&
            !booking_flow.in_state?(:definitive_request) && tenant.email.present?
        end
      end

      def booking
        context.fetch(:booking)
      end
    end
  end
end
