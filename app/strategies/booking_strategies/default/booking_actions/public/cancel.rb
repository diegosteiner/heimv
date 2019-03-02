module BookingStrategies
  class Default
    module BookingActions
      class Public
        class Cancel < BookingStrategy::BookingAction
          def call!
            @booking.state_machine.transition_to(:cancelation_pending)
          end

          def allowed?
            @booking.state_machine.can_transition_to?(:cancelation_pending)
          end

          def button_options
            super.merge(
              class: %i[btn btn-outline-danger],
              data: {
                confirm: I18n.t(:confirm)
              }
            )
          end
        end
      end
    end
  end
end
