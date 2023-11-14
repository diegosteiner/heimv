# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailInvoices < BookingActions::Base
      MailTemplate.define(:payment_due_notification, context: %i[booking invoices])

      def call!
        mail = MailTemplate.use!(:payment_due_notification, booking, to: :tenant, invoices:)
        mail.save! && invoices.each(&:sent!)

        Result.new ok: mail.valid?, redirect_proc: proc { edit_manage_notification_path(mail) }
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

      def operator
        booking.responsibilities[:billing]
      end
    end
  end
end
