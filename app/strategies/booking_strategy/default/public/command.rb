module BookingStrategy
  module Default
    module Public
      class Command < BookingStrategy::Base::Command
        def cancel
          @booking.state_machine.transition_to(:cancelled) unless @booking.state_machine.in_state?(:cancelled)
        end

        def extend_deadline
          @booking.errors.add(:base, :not_extendable) && (return false) unless @booking.deadline.extendable?

          case @booking.current_state.to_sym
          when :provisional_request
            @booking.deadline.extend_until(14.days.from_now)
          when :overdue_request
            @booking.state_machine.transition_to(:provisional_request)
          when :payment_overdue
            @booking.state_machine.transition_to(:payment_due)
          end
        end
      end
    end
  end
end
