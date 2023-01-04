# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailInvoice < BookingActions::Base
      RichTextTemplate.require_template(:payment_due_notification, template_context: %i[booking], required_by: self)

      def call!
        notification = prepare_notification
        notification.deliver && invoices.each(&:sent!)
        notification.dup.tap { _1.to = operator }.deliver if operator&.email.present?
      end

      def allowed?
        booking.instance_exec do
          notifications_enabled && invoices.unsent.any? &&
            !booking_flow.in_state?(:definitive_request) && tenant.email.present?
        end
      end

      protected

      def booking
        context.fetch(:booking)
      end

      def invoices
        booking.invoices.unsent
      end

      def prepare_notification
        booking.notifications.new(template: :payment_due_notification, to: booking.tenant,
                                  template_context: { invoices: invoices }) do |notification|
          notification.attach(prepare_attachments)
        end
      end

      def prepare_attachments
        invoices.with_default_includes.includes([:pdf_blob, { pdf_attachment: [:blob] }])
                .map { |invoice| invoice.pdf.blob }
      end

      def operator
        booking.responsibilities[:billing]
      end
    end
  end
end
