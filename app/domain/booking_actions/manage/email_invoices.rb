# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailInvoices < BookingActions::Base
      MailTemplate.define(:payment_due_notification, context: %i[booking invoices])

      def call!
        notification = prepare_notification
        notification.save! && invoices.each(&:sent!)

        Result.new ok: notification.valid?, redirect_proc: redirect_proc(notification)
      end

      def allowed?
        invoices.any? && booking.notifications_enabled &&
          !booking.booking_flow.in_state?(:definitive_request) && booking.tenant.email.present?
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

      def invoices
        context[:invoices].presence ||
          booking.invoices.unsent.where(type: [Invoices::Deposit, Invoices::Invoice, Invoices::LateNotice].map(&:to_s))
      end

      def prepare_notification
        booking.notifications.new(template: :payment_due_notification, to: booking.tenant,
                                  template_context: { invoices: }) do |notification|
          notification.bcc = operator.email if operator&.email.present?
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
