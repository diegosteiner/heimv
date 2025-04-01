# frozen_string_literal: true

module BookingActions
  class MarkContractSigned < Base
    use_mail_template(:contract_signed_notification, context: %i[booking], autodeliver: false)
    use_mail_template(:operator_contract_signed_notification, context: %i[booking])

    def invoke!(signed_pdf: nil)
      booking.contract.update(signed_pdf:) if signed_pdf.present?
      booking.contract.signed!
      booking.update(committed_request: true)
      mail = MailTemplate.use(:contract_signed_notification, booking, to: :tenant)
      send_operator_notification
      Result.success redirect_proc: mail&.autodeliver_with_redirect_proc
    end

    def invoke_schema
      Dry::Schema.Params do
        optional(:signed_pdf).value(type?: ActionDispatch::Http::UploadedFile)
      end
    end

    def invokable?(signed_pdf: nil)
      booking.contract&.sent? && !booking.contract&.signed?
    end

    def invokable_with
      { prepare: true } if invokable?
    end

    protected

    def send_operator_notification
      Notification.dedup(booking, to: %i[administration billing home_handover home_return]) do |to|
        MailTemplate.use(:operator_contract_signed_notification, booking, to:)&.autodeliver!
      end
    end
  end
end
