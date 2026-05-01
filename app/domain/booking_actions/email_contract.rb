# frozen_string_literal: true

module BookingActions
  class EmailContract < Base
    use_mail_template(:email_contract_notification, context: %i[booking contract deposits], autodeliver: false)
    use_mail_template(:operator_email_contract_notification, context: %i[booking contract deposits], optional: true)

    delegate :contract, to: :booking

    def invoke!(deposit_ids: deposits.map(&:id), current_user: nil)
      deposits = self.deposits.where(id: deposit_ids)
      mail = notify_tenant(deposits)
      notify_operators(deposits)

      Result.success redirect_proc: mail&.autodeliver_with_redirect_proc
    end

    def invokable?(deposit_ids: nil, current_user: nil)
      booking.valid? && MailTemplate.enabled?(:email_contract_notification, booking) &&
        contract.present? && !contract.sent? && booking.email.present?
    end

    def invokable_with(current_user: nil)
      return unless invokable?(current_user:)

      deposit_ids = deposits.map(&:to_param)
      if deposits.any?
        { label: translate(:label_with_invoice), params: { deposit_ids: } }
      else
        { label: translate(:label_without_invoice), confirm: translate(:confirm), params: { deposit_ids: [] } }
      end
    end

    def deposits
      @deposits ||= booking.invoices.where(type: Invoices::Deposit.to_s).kept.unsent
    end

    def invoke_schema
      Dry::Schema.Params do
        optional(:deposit_ids).array(:string)
      end
    end

    protected

    def notify_tenant(deposits)
      context = { contract:, deposit: deposits.one? ? deposits.first : nil, deposits: }
      MailTemplate.use!(:email_contract_notification, booking, to: :tenant, context:) do |mail|
        mail.attach :contract, deposits
        mail.save!
        deposits.find_each { it.update!(sent_with_notification: mail) }
        contract.update!(sent_with_notification: mail)
      end
    end

    def notify_operators(deposits)
      context = { contract:, deposit: deposits.one? ? deposits.first : nil, deposits: }
      Notification.dedup(booking, to: %i[billing home_handover home_return]) do |to|
        MailTemplate.use(:operator_email_contract_notification, booking, to:, context:)&.tap do |mail|
          mail.attach contract, deposits
          mail.autodeliver!
        end
      end
    end
  end
end
