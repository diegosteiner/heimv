module BookingStrategies
  class Default
    module BookingActions
      class Manage
        class EmailContractAndDeposit < BookingStrategy::BookingAction
          def call!(contract = @booking.contract, deposits = @booking.invoices.deposit, home = @booking.home)
            @booking.messages.new_from_template(:confirmed_message).deliver_now do |message|
              attachments = [
                home.house_rules.attachment&.blob,
                deposits.map { |deposit| deposit.pdf.blob },
                contract.pdf&.blob
              ]
              message.attachments.attach(attachments.flatten.compact)
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
