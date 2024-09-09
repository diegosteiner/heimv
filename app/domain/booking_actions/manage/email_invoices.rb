# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailInvoices < BookingActions::Base
      templates << MailTemplate.define(:payment_due_notification, context: %i[booking invoices], autodeliver: false)

      def invoke!(invoice_ids: nil)
        invoices = invoice_ids.present? ? booking.organisation.invoices.where(id: invoice_ids) : unsent_invoices
        mail = MailTemplate.use!(:payment_due_notification, booking, to: :tenant, invoices:)
        mail.attach(invoices)
        mail.save! && invoices.each(&:sent!)

        Result.success redirect_proc: mail&.autodeliver_with_redirect_proc
      end

      def allowed?
        unsent_invoices.any? && booking.notifications_enabled &&
          !booking.in_state?(:definitive_request) && booking.tenant.email.present?
      end

      protected

      def unsent_invoices
        booking.invoices.unsent.where(type: [Invoices::Deposit, Invoices::Invoice, Invoices::LateNotice].map(&:to_s))
      end

      def operator
        booking.roles[:billing]
      end
    end
  end
end
