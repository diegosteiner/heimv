module BookingStrategies
  class Default
    module Actions
      module Public
        class ExtendDeadline < BookingStrategy::Action
          def call!
            case @booking.current_state.to_sym
            when :provisional_request
              @booking.deadline.extend_until(14.days.from_now)
            when :overdue_request
              @booking.state_machine.transition_to(:provisional_request)
            when :payment_overdue
              @booking.state_machine.transition_to(:payment_due)
            end
          end

          def allowed?
            @booking.deadline&.extendable?
          end

          def button_options
            super.merge(
              class: %i[btn btn-outline-primary]
            )
          end
        end
      end
    end
  end
end
