# frozen_string_literal: true

module BookingActions
  class MarkContractSigned < Base
    use_mail_template(:contract_signed_notification, context: %i[booking], autodeliver: false)
    use_mail_template(:operator_contract_signed_notification, context: %i[booking], optional: true)

    def invoke!(signed_pdf: nil, current_user: nil) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      booking.contract.signed_pdf.attach(signed_pdf) if signed_pdf.present?
      Rails.logger.info "MarkContractSigned #{booking.contract.id} pdf attached"
      booking.contract.update!(signed_at: Time.zone.now)
      Rails.logger.info "MarkContractSigned #{booking.contract.id} contract signed"
      booking.update!(committed_request: true)
      Rails.logger.info "MarkContractSigned #{booking.contract.id} booking updated"

      mail = MailTemplate.use(:contract_signed_notification, booking, to: :tenant)
      Rails.logger.info "MarkContractSigned #{booking.contract.id} mail prepared: #{mail.inspect}"
      send_operator_notification
      Rails.logger.info "MarkContractSigned #{booking.contract.id} operators notified"
      Result.success redirect_proc: mail&.autodeliver_with_redirect_proc
    end

    def invoke_schema
      Dry::Schema.Params do
        optional(:signed_pdf).value(type?: ActionDispatch::Http::UploadedFile)
      end
    end

    def invokable?(signed_pdf: nil, current_user: nil)
      booking.contract&.sent? && !booking.contract&.signed? && booking.valid_with_attributes?(committed_request: true)
    end

    def invokable_with(current_user: nil)
      { prepare: true } if invokable?(current_user:)
    end

    protected

    def send_operator_notification
      Notification.dedup(booking, to: %i[billing home_handover home_return]) do |to|
        MailTemplate.use(:operator_contract_signed_notification, booking, to:)&.autodeliver!
      end
    end
  end
end
