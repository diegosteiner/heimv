# frozen_string_literal: true

module BookingActions
  class EmailContract < Base
    use_mail_template(:email_contract_notification, context: %i[booking contract invoices], autodeliver: false)
    use_mail_template(:operator_email_contract_notification, context: %i[booking contract invoices], optional: true)

    delegate :contract, to: :booking

    def invoke!(invoice_ids: invoices.map(&:id), quote_ids: quotes.map(&:id), current_user: nil)
      invoices = self.invoices.where(id: invoice_ids)
      quotes = self.quotes.where(id: quote_ids)
      mail = send_tenant_notification(invoices, quotes)

      send_operator_notification(invoices, quotes)

      Result.success redirect_proc: mail&.autodeliver_with_redirect_proc
    end

    def invokable?(invoice_ids: nil, current_user: nil)
      booking.valid? && booking.notifications_enabled && contract.present? && !contract.sent? &&
        booking.email.present?
    end

    def invokable_with(current_user: nil)
      return unless invokable?(current_user:)

      invoice_ids = invoices.map(&:to_param)
      quote_ids = quotes.map(&:to_param)
      if invoices.any?
        { label: translate(:label_with_invoice), params: { invoice_ids:, quote_ids: } }
      else
        { label: translate(:label_without_invoice), confirm: translate(:confirm),
          params: { invoice_ids: [], quote_ids: [] } }
      end
    end

    def invoices
      @invoices ||= booking.invoices.kept.unsent
    end

    def quotes
      @quotes ||= booking.quotes.unsent
    end

    def invoke_schema
      Dry::Schema.Params do
        optional(:invoice_ids).array(:string)
        optional(:quote_ids).array(:string)
      end
    end

    protected

    def send_tenant_notification(invoices, quotes)
      context = { contract:, invoices:, quotes: }
      MailTemplate.use!(:email_contract_notification, booking, to: :tenant, context:) do |mail|
        mail.attach :contract, invoices
        mail.save!
        invoices.each { it.update!(sent_with_notification: mail) }
        quotes.each { it.update!(sent_with_notification: mail) }
        contract.update!(sent_with_notification: mail)
      end
    end

    def send_operator_notification(invoices, quotes)
      context = { contract:, invoices:, quotes: }
      Notification.dedup(booking, to: %i[billing home_handover home_return]) do |to|
        MailTemplate.use(:operator_email_contract_notification, booking, to:, context:)&.tap do |mail|
          mail.attach contract, invoices, quotes
          mail.autodeliver!
        end
      end
    end
  end
end
