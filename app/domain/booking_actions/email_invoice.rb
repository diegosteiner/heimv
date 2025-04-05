# frozen_string_literal: true

module BookingActions
  class EmailInvoice < Base
    use_mail_template(:email_invoice_notification, context: %i[booking invoice], autodeliver: false)
    use_mail_template(:operator_email_invoice_notification, context: %i[booking invoice], optional: true)

    def invoke!(invoice_id:, current_user: nil)
      invoice = booking.organisation.invoices.where(id: invoice_id)
      mail = send_tenant_notification(invoice)
      send_operator_notification(invoice)

      Result.success redirect_proc: mail&.autodeliver_with_redirect_proc
    end

    def invokable?(invoice_id:, current_user: nil)
      booking.notifications_enabled && booking.tenant.email.present? &&
        unsent_invoices.exists?(id: invoice_id)
    end

    def invokable_with
      unsent_invoices.where(type: Invoices::Invoice.sti_name).filter_map do |invoice|
        next unless invokable?(invoice_id: invoice.id)

        { label: translate(:label_with_ref, type: invoice.model_name.human, ref: invoice.ref),
          params: { invoice_id: invoice.to_param } }
      end
    end

    def invoke_schema
      Dry::Schema.Params do
        optional(:invoice_id).filled(:string)
      end
    end

    protected

    def send_tenant_notification(invoice)
      context = { invoice: }
      MailTemplate.use!(:email_invoice_notification, booking, to: :tenant, context:).tap do |mail|
        mail.attach(invoice)
        mail.save!
        invoice.update!(sent_with_notification: mail)
      end
    end

    def send_operator_notification(invoice)
      context = { invoice: }
      MailTemplate.use(:operator_email_invoice_notification, booking, to: :billing, context:)&.tap do |mail|
        mail.attach(invoice)
        mail.autodeliver!
      end
    end

    def unsent_invoices
      booking.invoices.unsent.where(type: %w[Invoices::Deposit Invoices::Invoice Invoices::LateNotice])
    end
  end
end
