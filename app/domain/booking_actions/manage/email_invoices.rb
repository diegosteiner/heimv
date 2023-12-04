# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailInvoices < BookingActions::Base
      templates << MailTemplate.define(:payment_due_notification, context: %i[booking invoices], autodeliver: false)

      def call!
        mail = MailTemplate.use!(:payment_due_notification, booking, to: :tenant, invoices:)
        mail.attach(invoices)
        mail.save! && invoices.each(&:sent!)

        Result.ok redirect_proc: !mail.autodeliver && proc { edit_manage_notification_path(mail) }
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
        booking.roles[:billing]
      end
    end
  end
end
