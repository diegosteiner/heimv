module BookingStrategy
  module Default
    module Public
      class Command < BookingStrategy::Base::Command
        def cancel
          @booking.state_machine.transition_to(:cancelled)
        end

        def extend_deadline
          unless @booking.deadline.extendable?
            @booking.errors.add(:base, :not_extendable)
            return false
          end

          case @booking.current_state
          when 'overdue_request'
            @booking.state_machine.transition_to(:provisional_request)
          when 'payment_overdue'
            @booking.state_machine.transition_to(:payment_due)
          end
        end
      end
    end
  end
end
