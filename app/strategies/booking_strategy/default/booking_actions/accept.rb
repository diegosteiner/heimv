module BookingStrategy
  class Default
    module BookingActions
      class Accept < BookingStrategy::Base::BookingActions::Base
        def call(booking)
          booking.state_machine.transition_to(booking.committed_request ? :definitive_request : :provisional_request)
        end

        def self.available_on?(booking)
          booking.state_machine.can_transition_to?(:definitive_request) ||
            booking.state_machine.can_transition_to?(:provisional_request)
        end
      end
    end
  end
end
