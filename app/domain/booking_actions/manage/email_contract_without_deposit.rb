# frozen_string_literal: true

module BookingActions
  module Manage
    class EmailContractWithoutDeposit < EmailContractAndDeposit
      RichTextTemplate.require_template(:awaiting_contract_notification, template_context: %i[booking],
                                                                         required_by: self)

      def call!(contract = booking.contract)
        notification = prepare_notification
        notification.save! && contract.sent!

        Result.new ok: notification.valid?, redirect_proc: redirect_proc(notification)
      end

      def allowed?
        booking.instance_exec do
          notifications_enabled && committed_request && contract.present? && !contract.sent? &&
            tenant.email.present? && Invoices::Deposit.of(self).kept.none?
        end
      end

      def button_options
        super.merge(
          data: {
            confirm: translate(:confirm)
          }
        )
      end

      private

      def redirect_proc(notification)
        return unless notification&.persisted?

        proc do
          edit_manage_notification_path(notification)
        end
      end

      def prepare_attachments(booking, contract)
        [
          DesignatedDocument.for_booking(booking).where(send_with_contract: true),
          contract.pdf
        ].flatten.compact
      end

      def prepare_notification
        booking.notifications.new(template: :awaiting_contract_notification, to: booking.tenant,
                                  template_context: { contract: contract }).tap do |notification|
          notification.attach(prepare_attachments(booking, contract))
        end
      end

      def booking
        context.fetch(:booking)
      end
    end
  end
end
