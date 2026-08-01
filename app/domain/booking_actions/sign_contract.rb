# frozen_string_literal: true

module BookingActions
  class SignContract < Base
    use_mail_template(:manage_contract_signed_notification, context: %i[booking], autodeliver: true)

    def invoke!(signed_pdf: nil, tenant_confirm_authorization: nil, current_user: nil) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/AbcSize,Metrics/MethodLength
      if sign_by_click_enabled?
        return Result.failure unless tenant_confirm_authorization
      elsif signed_pdf.blank?
        return Result.failure
      elsif !contract.update(signed_pdf:)
        return Result.failure(error: contract.errors.full_messages.to_sentence)
      end

      booking.update(committed_request: true)
      mail = MailTemplate.use(:manage_contract_signed_notification, booking, to: :administration)
      mail.attach(signed_pdf) if mail.present? && signed_pdf.present?
      Result.success redirect_proc: mail&.autodeliver_with_redirect_proc
    end

    def invokable?(signed_pdf: nil, tenant_confirm_authorization: nil, current_user: nil)
      contract&.sent? && !contract&.confirmed? && !contract&.tenant_signed?
    end

    def invokable_with(current_user: nil)
      { prepare: true } if invokable?(current_user:)
    end

    def invoke_schema
      Dry::Schema.Params do
        optional(:signed_pdf).value(type?: ActionDispatch::Http::UploadedFile)
        optional(:tenant_confirm_authorization).filled(:bool)
      end
    end

    def sign_by_click_enabled?
      booking.organisation.settings.contract_sign_by_click_enabled
    end

    def label
      t(sign_by_click_enabled? ? :label_sign_by_click : :label_upload)
    end

    protected

    def contract
      @contract ||= booking.contract
    end
  end
end
