# frozen_string_literal: true

module BookingActions
  class EmailOffer < Base
    use_mail_template(:email_offer_notification, context: %i[booking offer], optional: true, autodeliver: false)

    def invoke!(offer_id:, current_user: nil)
      offer = booking.organisation.invoices.find_by(type: Invoices::Offer.sti_name, id: offer_id)
      mail = send_tenant_notification(offer)

      Result.success redirect_proc: mail&.autodeliver_with_redirect_proc
    end

    def invokable?(offer_id:, current_user: nil)
      booking.notifications_enabled && booking.tenant.email.present? && unsent_offers.exists?(id: offer_id)
    end

    def invokable_with
      unsent_offers.filter_map do |offer|
        next unless invokable?(offer_id: offer.id)

        { label:, params: { offer_id: offer.to_param } }
      end
    end

    def invoke_schema
      Dry::Schema.Params do
        optional(:offer_id).filled(:string)
      end
    end

    protected

    def send_tenant_notification(offer)
      context = { offer: }
      MailTemplate.use!(:email_offer_notification, booking, to: :tenant, context:).tap do |mail|
        mail.attach(offer)
        mail.save!
        offer.update!(sent_at: Time.zone.now)
      end
    end

    def unsent_offers
      booking.invoices.where(type: Invoices::Offer.sti_name).kept.unsent
    end
  end
end
