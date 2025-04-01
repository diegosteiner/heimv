# frozen_string_literal: true

module BookingActions
  class EmailContract < Base
    use_mail_template(:email_contract_notification, context: %i[booking contract invoices], autodeliver: false)
    use_mail_template(:operator_email_contract_notification, context: %i[booking contract invoices], optional: true)

    delegate :contract, to: :booking

    def invoke!(deposit_ids: deposits.map(&:id))
      deposits = self.deposits.where(id: deposit_ids)
      mail = send_tenant_notification(deposits)

      send_operator_notification(deposits)

      Result.success redirect_proc: mail&.autodeliver_with_redirect_proc
    end

    def invokable?(deposit_ids: nil)
      booking.valid? && booking.notifications_enabled && contract.present? && !contract.sent? &&
        booking.email.present?
    end

    def invokable_with
      return unless invokable?

      deposit_ids = deposits.map(&:to_param)
      if deposits.any?
        { label: translate(:label_with_deposit), params: { deposit_ids: } }
      else
        { label: translate(:label_without_deposit), confirm: translate(:confirm), params: { deposit_ids: [] } }
      end
    end

    def deposits
      @deposits ||= booking.invoices.kept.unsent.deposits
    end

    def invoke_schema
      Dry::Schema.Params do
        optional(:deposit_ids).array(:string)
      end
    end

    protected

    def send_tenant_notification(deposits)
      context = { contract:, invoices: deposits }
      MailTemplate.use!(:email_contract_notification, booking, to: :tenant, context:) do |mail|
        mail.attach :contract, deposits
        mail.save!
        deposits.each { it.update!(sent_with_notification: mail) }
        contract.update!(sent_with_notification: mail)
      end
    end

    def send_operator_notification(deposits)
      context = { contract:, invoices: deposits }
      Notification.dedup(booking, to: %i[billing home_handover home_return]) do |to|
        MailTemplate.use(:operator_email_contract_notification, booking, to:, context:)&.tap do |mail|
          mail.attach contract, deposits
          mail.autodeliver!
        end
      end
    end
  end
end
