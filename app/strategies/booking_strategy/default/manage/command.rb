module BookingStrategy
  module Default
    module Manage
      class Command < BookingStrategy::Default::Public::Command
        def accept
          @booking.state_machine.transition_to @booking.committed_request ? :definitive_request : :provisional_request
        end

        def email_contract_and_deposit
          @booking.messages.new_from_template(:confirmed_message)&.deliver_now do |message|
            message.attachments.attach(@booking.contract&.pdf&.blob)
            message.attachments.attach(@booking.invoices.deposit.map { |deposit| deposit.pdf.blob })
          end
        end
      end
    end
  end
end
