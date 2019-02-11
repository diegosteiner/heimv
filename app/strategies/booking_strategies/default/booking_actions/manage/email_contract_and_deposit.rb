module BookingStrategies
  class Default
    module BookingActions
      class Manage
        class EmailContractAndDeposit < BookingStrategy::BookingAction
          def call!(contract = @booking.contract, deposits = @booking.invoices.deposit)
            @booking.messages.new_from_template(:confirmed_message).deliver_now do |message|
              message.attachments.attach(contract.pdf&.blob)
              message.attachments.attach(deposits.map { |deposit| deposit.pdf.blob })
            end && contract.sent! && deposits.each(&:sent!)
          end

          def allowed?
            @booking.contract.present? && !@booking.contract.sent?
          end
        end
      end
    end
  end
end
