# frozen_string_literal: true

module BookingActions
  class EmailContract < Base
    use_mail_template(:email_contract_notification, context: %i[booking contract deposits], autodeliver: false)
    use_mail_template(:operator_email_contract_notification, context: %i[booking contract deposits], optional: true)

    delegate :contract, to: :booking

    def invoke!(deposit_ids: deposits.map(&:id), offer_ids: offers.map(&:id), current_user: nil)
      deposits = self.deposits.where(id: deposit_ids)
      offers = self.offers.where(id: offer_ids)
      mail = notify_tenant(deposits, offers)
      notify_operators(deposits, offers)

      Result.success redirect_proc: mail&.autodeliver_with_redirect_proc
    end

    def invokable?(deposit_ids: nil, current_user: nil)
      booking.valid? && MailTemplate.enabled?(:email_contract_notification, booking) &&
        contract.present? && !contract.sent? && booking.email.present?
    end

    def invokable_with(current_user: nil)
      return unless invokable?(current_user:)

      if deposits.any?
        { label: translate(:label_with_deposits),
          params: { deposit_ids: deposits.filter_map(&:to_param), offer_ids: offers.filter_map(&:to_param) } }
      elsif offers.any?
        { label: translate(:label_with_offers), params: { offer_ids: offers.filter_map(&:to_param) } }
      else
        { label: translate(:label_contract_only), confirm: translate(:confirm), params: { deposit_ids: [] } }
      end
    end

    def deposits
      @deposits ||= booking.invoices.where(type: %w[Invoices::Deposit]).kept.unsent
    end

    def offers
      @offers ||= booking.invoices.where(type: %w[Invoices::Offer]).kept.unsent
    end

    def invoke_schema
      Dry::Schema.Params do
        optional(:deposit_ids).array(:string)
      end
    end

    protected

    def notify_tenant(deposits, offers)
      context = { contract:, deposit: deposits.one? ? deposits.first : nil, deposits:,
                  offer: offers.one? ? offers.first : nil, offers: }
      MailTemplate.use!(:email_contract_notification, booking, to: :tenant, context:) do |mail|
        mail.attach :contract, deposits, offers
        mail.save!
        deposits&.find_each { it.update!(sent_with_notification: mail) }
        offers&.find_each { it.update!(sent_with_notification: mail) }
        contract.update!(sent_with_notification: mail)
      end
    end

    def notify_operators(deposits, offers)
      context = { contract:, deposit: deposits.one? ? deposits.first : nil, deposits:,
                  offer: offers.one? ? offers.first : nil, offers: }
      operators = %i[home_handover home_return]
      operators << :billing if deposits.present?
      Notification.dedup(booking, to: operators) do |to|
        MailTemplate.use(:operator_email_contract_notification, booking, to:, context:)&.tap do |mail|
          mail.attach contract, deposits, offers
          mail.autodeliver!
        end
      end
    end
  end
end
