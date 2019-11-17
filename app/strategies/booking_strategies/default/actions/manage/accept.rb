module BookingStrategies
  class Default
    module Actions
      module Manage
        class Accept < BookingStrategy::Action
          def call!
            transition_to = if booking.agent_booking?
                              :booking_agent_request
                            elsif booking.committed_request
                              :definitive_request
                            else
                              :provisional_request
                            end

            booking.state_machine.transition_to(transition_to)
          end

          def allowed?
            booking.state_machine.yield_self do |state_machine|
              state_machine.in_state?(:open_request) &&
                state_machine.can_transition_to?(:definitive_request) ||
                state_machine.can_transition_to?(:provisional_request) ||
                state_machine.can_transition_to?(:booking_agent_request)
            end
          end

          def button_options
            super.merge(
              variant: 'success'
            )
          end

          def booking
            context.fetch(:booking)
          end
        end
      end
    end
  end
end
