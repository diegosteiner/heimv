module BookingStrategy
  class Default
    module BookingActions
      class EmailContractAndDeposit < BookingStrategy::Base::BookingAction
        def call(booking, contract = booking.contract, deposits = booking.invoices.deposit)
          booking.messages.new_from_template(:confirmed_message).deliver_now do |message|
            message.attachments.attach(contract.pdf&.blob)
            message.attachments.attach(deposits.map { |deposit| deposit.pdf.blob })
          end && contract.sent! && deposits.each(&:sent!)
        end

        def self.available_on?(booking)
          booking.contract.present? && !booking.contract.sent?
        end
      end
    end
  end
end
