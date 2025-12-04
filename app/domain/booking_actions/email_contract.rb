# frozen_string_literal: true

module BookingActions
  class EmailContract < Base
    use_mail_template(:email_contract_notification, context: %i[booking contract invoices], autodeliver: false)
    use_mail_template(:operator_email_contract_notification, context: %i[booking contract invoices], optional: true)

    delegate :contract, to: :booking

    def invoke!(invoice_ids: invoices.map(&:id), current_user: nil)
      invoices = self.invoices.where(id: invoice_ids)
      mail = send_tenant_notification(invoices)

      send_operator_notification(invoices)

      Result.success redirect_proc: mail&.autodeliver_with_redirect_proc
    end

    def invokable?(invoice_ids: nil, current_user: nil)
      booking.valid? && booking.notifications_enabled && MailTemplate.enabled?(:email_contract_notification, booking) &&
        contract.present? && !contract.sent? && booking.email.present?
    end

    def invokable_with(current_user: nil)
      return unless invokable?(current_user:)

      invoice_ids = invoices.map(&:to_param)
      if invoices.any?
        { label: translate(:label_with_invoice), params: { invoice_ids: } }
      else
        { label: translate(:label_without_invoice), confirm: translate(:confirm), params: { invoice_ids: [] } }
      end
    end

    def invoices
      @invoices ||= booking.invoices.kept.unsent
    end

    def invoke_schema
      Dry::Schema.Params do
        optional(:invoice_ids).array(:string)
      end
    end

    protected

    def send_tenant_notification(invoices)
      context = { contract:, invoices: }
      MailTemplate.use!(:email_contract_notification, booking, to: :tenant, context:) do |mail|
        mail.attach :contract, invoices
        mail.save!
        invoices.each { it.update!(sent_with_notification: mail) }
        contract.update!(sent_with_notification: mail)
      end
    end

    def send_operator_notification(invoices)
      context = { contract:, invoices: }
      Notification.dedup(booking, to: %i[billing home_handover home_return]) do |to|
        MailTemplate.use(:operator_email_contract_notification, booking, to:, context:)&.tap do |mail|
          mail.attach contract, invoices
          mail.autodeliver!
        end
      end
    end
  end
end
