# frozen_string_literal: true

module BookingActions
  class MarkContractSigned < Base
    use_mail_template(:contract_signed_notification, context: %i[booking], autodeliver: false)
    use_mail_template(:operator_contract_signed_notification, context: %i[booking], optional: true)

    def invoke!(signed_pdf: nil, current_user: nil) # rubocop:disable Metrics/AbcSize
      booking.contract.signed_pdf.attach(signed_pdf) if signed_pdf.present?
      return Result.success if booking.contract.signed?

      booking.contract.update!(signed_at: Time.zone.now)
      booking.update!(committed_request: true)

      mail = MailTemplate.use(:contract_signed_notification, booking, to: :tenant)
      send_operator_notification

      Result.success redirect_proc: mail&.autodeliver_with_redirect_proc
    end

    def invoke_schema
      Dry::Schema.Params do
        optional(:signed_pdf).value(type?: ActionDispatch::Http::UploadedFile)
      end
    end

    def invokable?(signed_pdf: nil, current_user: nil)
      booking.contract&.sent? && booking.valid_with_attributes?(committed_request: true)
    end

    def invokable_with(current_user: nil)
      { prepare: true } if invokable?(current_user:) && !booking.contract&.signed?
    end

    protected

    def send_operator_notification
      Notification.dedup(booking, to: %i[billing home_handover home_return]) do |to|
        MailTemplate.use(:operator_contract_signed_notification, booking, to:)&.autodeliver!
      end
    end
  end
end
