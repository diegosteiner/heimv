# frozen_string_literal: true

module BookingActions
  class EmailInvoice < Base
    use_mail_template(:email_invoice_notification, context: %i[booking invoice invoices], autodeliver: false)
    use_mail_template(:operator_email_invoice_notification, context: %i[booking invoice invoices], optional: true)

    def invoke!(invoice_ids:, current_user: nil)
      invoices = booking.organisation.invoices.where(id: invoice_ids)
      mail = notify_tenant(invoices)
      notify_operators(invoices)

      Result.success redirect_proc: mail&.autodeliver_with_redirect_proc
    end

    def invokable?(invoice_ids:, current_user: nil)
      MailTemplate.enabled?(:email_contract_notification, booking) &&
        booking.tenant.email.present? && unsent_invoices.exists?(id: invoice_ids)
    end

    def invokable_with(current_user: nil)
      invoice_ids = unsent_invoices.where(type: %w[Invoices::Deposit Invoices::Invoice]).filter_map do |invoice|
        next invoice.id if invoice.is_a?(Invoices::Invoice)
        next invoice.id if invoice.is_a?(Invoices::Deposit) && !booking.contract&.sent?

        nil
      end

      { params: { invoice_ids: } } if invokable?(invoice_ids:, current_user:)
    end

    def invoke_schema
      Dry::Schema.Params do
        optional(:invoice_ids).array(:string)
      end
    end

    protected

    def notify_tenant(invoices)
      context = { invoice: invoices.one? ? invoices.first : nil, invoices: }
      MailTemplate.use!(:email_invoice_notification, booking,
                        to: :tenant, cc: booking.invoice_cc, context:).tap do |mail|
        mail.attach(invoices)
        mail.save!
        invoices.find_each { it.update!(sent_with_notification: mail) }
      end
    end

    def notify_operators(invoices)
      context = { invoice: invoices.one? ? invoices.first : nil, invoices: }
      MailTemplate.use(:operator_email_invoice_notification, booking, to: :billing, context:)&.tap do |mail|
        mail.attach(invoices)
        mail.autodeliver!
      end
    end

    def unsent_invoices
      booking.invoices.unsent.where(type: %w[Invoices::Deposit Invoices::Invoice Invoices::LateNotice])
    end
  end
end
