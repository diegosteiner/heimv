# frozen_string_literal: true

module BookingActions
  class MarkContractSigned < Base
    use_mail_template(:contract_signed_notification, context: %i[booking], autodeliver: false)

    def invoke!(signed_pdf: nil)
      booking.contract.update(signed_pdf:) if signed_pdf.present?
      booking.contract.signed!
      booking.update(committed_request: true)
      mail = MailTemplate.use(:contract_signed_notification, booking, to: :tenant)
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
  end
end
