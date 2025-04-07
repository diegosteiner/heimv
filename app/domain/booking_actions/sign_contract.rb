# frozen_string_literal: true

module BookingActions
  class SignContract < Base
    use_mail_template(:manage_contract_signed_notification, context: %i[booking], autodeliver: true)

    def invoke!(signed_pdf: nil, confirm_authorization: nil, current_user: nil)
      return Result.failure unless confirm_authorization

      contract.update(signed_pdf:) if signed_pdf.present?
      contract.signed!
      booking.update(committed_request: true)

      mail = MailTemplate.use(:manage_contract_signed_notification, booking, to: :administration)
      mail.attach(signed_pdf) if mail.present? && signed_pdf.present?
      Result.success redirect_proc: mail&.autodeliver_with_redirect_proc
    end

    def invokable?(signed_pdf: nil, confirm_authorization: nil, current_user: nil)
      booking.organisation.settings.contract_sign_by_click_enabled &&
        contract&.sent? && !contract&.signed?
    end

    def invokable_with
      { prepare: true } if invokable?
    end

    def invoke_schema
      Dry::Schema.Params do
        optional(:signed_pdf).value(type?: ActionDispatch::Http::UploadedFile)
        optional(:confirm_authorization).filled(:bool)
      end
    end

    protected

    def contract
      booking.contract
    end
  end
end
