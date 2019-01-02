module BookingStrategy
  module Default
    module Manage
      class Command < BookingStrategy::Base::Command
        def cancel
          @booking.state_machine.transition_to(:cancelled)
        end

        def accept
          @booking.state_machine.transition_to((@booking.committed_request? ? :definitive_request : :provisional_request))
        end

        def extend_deadline
          case @booking.current_state
          when 'overdue_request'
            @booking.state_machine.transition_to(:provisional_request)
          when 'payment_overdue'
            @booking.state_machine.transition_to(:payment_due)
          end
        end

        def email_contract_and_deposit
          @booking.messages.new_from_template(:confirmed_message)&.tap do |message|
            message.attachments.attach @booking.contracts.valid.last&.pdf&.blob
            @booking.invoices.deposit.each { |deposit| message.attachments.attach(deposit.pdf.blob) }
            message.save_and_deliver_now
          end
        end
      end
    end
  end
end
