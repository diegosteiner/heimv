# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailInvoices < BookingActions::Base
      templates << MailTemplate.define(:payment_due_notification, context: %i[booking invoices], autodeliver: false)
      templates << MailTemplate.define(:operator_invoice_sent_notification, context: %i[booking invoices],
                                                                            optional: true)

      def invoke!(invoice_ids: nil)
        invoices = invoice_ids.present? ? booking.organisation.invoices.where(id: invoice_ids) : unsent_invoices
        mail = send_tenant_notification(invoices)
        send_operator_notification(invoices) if mail.persisted?

        Result.success redirect_proc: mail&.autodeliver_with_redirect_proc
      end

      def allowed?
        unsent_invoices.any? && booking.notifications_enabled && booking.tenant.email.present? &&
          !EmailContract.new(booking).allowed?
      end

      protected

      def send_tenant_notification(invoices)
        context = { invoices: }
        MailTemplate.use!(:payment_due_notification, booking, to: :tenant, context:).tap do |mail|
          mail.attach(invoices)
          mail.save! && invoices.each(&:sent!)
        end
      end

      def send_operator_notification(invoices)
        context = { invoices: }
        MailTemplate.use(:operator_invoice_sent_notification, booking, to: :billing, context:)&.tap do |mail|
          mail.attach(invoices)
          mail.autodeliver!
        end
      end

      def unsent_invoices
        booking.invoices.unsent.where(type: [Invoices::Deposit, Invoices::Invoice,
                                             Invoices::LateNotice].map(&:sti_name))
      end

      def operator
        booking.roles[:billing]
      end
    end
  end
end
