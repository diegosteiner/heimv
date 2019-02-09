module BookingStrategy
  class Default
    module BookingActions
      class Cancel < BookingStrategy::Base::BookingAction
        def call(booking)
          booking.state_machine.transition_to(:cancelled) unless booking.state_machine.in_state?(:cancelled)
        end

        def self.available_on?(booking)
          booking.state_machine.can_transition_to?(:cancelled)
        end

        def variant
          :'outline-danger'
        end
      end
    end
  end
end
