# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailInvoices < BookingActions::Base
      RichTextTemplate.require_template(:payment_due_notification, template_context: %i[booking invoices],
                                                                   required_by: self)

      def call!
        notification = prepare_notification
        notification.deliver && invoices.each(&:sent!)
        notification.dup.tap { _1.to = operator }.deliver if operator&.email.present?
      end

      def allowed?
        invoices.any? && booking.notifications_enabled &&
          !booking.booking_flow.in_state?(:definitive_request) && booking.tenant.email.present?
      end

      protected

      def booking
        context.fetch(:booking)
      end

      def invoices
        context[:invoices].presence ||
          booking.invoices.unsent.where(type: [Invoices::Deposit, Invoices::Invoice, Invoices::LateNotice].map(&:to_s))
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
