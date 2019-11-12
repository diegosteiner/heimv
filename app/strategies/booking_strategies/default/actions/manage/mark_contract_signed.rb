module BookingStrategies
  class Default
    module Actions
      module Manage
        class MarkContractSigned < BookingStrategy::Action
          def call!
            if @booking.invoices.deposit.unpaid.exists?
              @booking.messages.new_from_template(:contract_signed_message, addressed_to: :tenant)&.deliver_now
            end

            @booking.contract.signed!
          end

          def allowed?
            @booking.contract&.sent? && !@booking.contract&.signed?
          end
        end
      end
    end
  end
end
