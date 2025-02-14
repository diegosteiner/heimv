# frozen_string_literal: true

module BookingActions
  module Public
    class SignContract < BookingActions::Base
      templates << MailTemplate.define(:contract_signed_notification, context: %i[booking], autodeliver: false)

      def invoke!(signed_pdf: nil, confirm_authorization: nil)
        return Result.failure unless confirm_authorization

        booking.contract.update(signed_pdf:) if signed_pdf.present?
        booking.contract.signed!
        booking.update(committed_request: true)

        mail = MailTemplate.use(:contract_signed_notification, booking, to: :tenant)
        Result.success redirect_proc: mail&.autodeliver
      end

      def allowed?
        booking.organisation.settings.contract_sign_by_click_enabled &&
          booking.contract&.sent? && !booking.contract&.signed?
      end

      def prepare?
        true
      end

      def self.params_schema
        Dry::Schema.Params do
          optional(:signed_pdf).value(type?: ActionDispatch::Http::UploadedFile)
          optional(:confirm_authorization).filled(:bool)
        end
      end

      protected

      def deposits
        Invoices::Deposit.of(booking).unpaid
      end
    end
  end
end
