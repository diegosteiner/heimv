# frozen_string_literal: true

module BookingActions
  class EmailQuote < Base
    use_mail_template(:email_quote_notification, context: %i[booking quote], optional: true, autodeliver: false)

    def invoke!(quote_id:, current_user: nil)
      quote = booking.organisation.quotes.find_by(id: quote_id)
      mail = send_tenant_notification(quote)

      Result.success redirect_proc: mail&.autodeliver_with_redirect_proc
    end

    def invokable?(quote_id:, current_user: nil)
      booking.notifications_enabled && booking.tenant.email.present? && unsent_quotes.exists?(id: quote_id)
    end

    def invokable_with(current_user: nil)
      unsent_quotes.filter_map do |quote|
        next unless invokable?(quote_id: quote.id, current_user:)

        { label:, params: { quote_id: quote.to_param } }
      end
    end

    def invoke_schema
      Dry::Schema.Params do
        optional(:quote_id).filled(:string)
      end
    end

    protected

    def send_tenant_notification(quote)
      context = { quote: }
      MailTemplate.use!(:email_quote_notification, booking, to: :tenant, context:).tap do |mail|
        mail.attach(quote)
        mail.save!
        quote.update!(sent_at: Time.zone.now)
      end
    end

    def unsent_quotes
      booking.quotes.kept.unsent
    end
  end
end
