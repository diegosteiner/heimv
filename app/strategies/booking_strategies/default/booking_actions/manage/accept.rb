module BookingStrategies
  class Default
    module BookingActions
      class Manage
        class Accept < BookingStrategy::BookingAction
          def call!
            @booking.state_machine.transition_to(if @booking.committed_request
                                                   :definitive_request
                                                 else
                                                   :provisional_request
                                                 end)
          end

          def allowed?
            @booking.state_machine.can_transition_to?(:definitive_request) ||
              @booking.state_machine.can_transition_to?(:provisional_request)
          end
        end
      end
    end
  end
end
