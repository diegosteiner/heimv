module BookingStrategies
  class Default
    module BookingActions
      class Manage
        class Cancel < BookingStrategy::BookingAction
          def call!
            @booking.state_machine.transition_to(:cancelation_pending)
          end

          def allowed?
            @booking.state_machine.can_transition_to?(:cancelation_pending)
          end

          def variant
            :'outline-danger'
          end
        end
      end
    end
  end
end
