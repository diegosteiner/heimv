# frozen_string_literal: true

module BookingActions
  class SignContract < Base
    use_mail_template(:tenant_contract_signed_notification, context: %i[booking], autodeliver: false)

    def invoke!(signed_pdf: nil, confirm_authorization: nil)
      return Result.failure unless confirm_authorization

      booking.contract.update(signed_pdf:) if signed_pdf.present?
      booking.contract.signed!
      booking.update(committed_request: true)

      mail = MailTemplate.use(:tenant_contract_signed_notification, booking, to: :manage)
      Result.success redirect_proc: mail&.autodeliver
    end

    def invokable?(**)
      booking.organisation.settings.contract_sign_by_click_enabled &&
        booking.contract&.sent? && !booking.contract&.signed?
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

    def deposits
      Invoices::Deposit.of(booking).kept.unpaid
    end
  end
end
