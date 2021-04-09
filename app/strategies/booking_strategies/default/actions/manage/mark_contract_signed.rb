# frozen_string_literal: true

module BookingStrategies
  class Default
    module Actions
      module Manage
        class MarkContractSigned < BookingStrategy::Action
          Default.require_rich_text_template(:contract_signed_notification, %i[booking])

          def call!
            if Invoices::Deposit.of(booking).kept.unpaid.exists?
              booking.notifications.new(from_template: :contract_signed_notification, addressed_to: :tenant).deliver
            end

            booking.contract.signed!
          end

          def allowed?
            booking.contract&.sent? && !booking.contract&.signed?
          end

          def booking
            context.fetch(:booking)
          end
        end
      end
    end
  end
end
