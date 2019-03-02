module BookingStrategies
  class Default
    module BookingActions
      class Manage
        class MarkContractSigned < BookingStrategy::BookingAction
          def call!
            if @booking.invoices.deposit.unpaid.exists?
              @booking.messages.new_from_template(:contract_signed_message)&.deliver_now
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
