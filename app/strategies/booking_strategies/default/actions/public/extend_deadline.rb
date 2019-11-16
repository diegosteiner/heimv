module BookingStrategies
  class Default
    module Actions
      module Public
        class ExtendDeadline < BookingStrategy::Action
          def call!
            case @booking.current_state.to_sym
            when :provisional_request
              extend_provisional_request(@booking)
            when :overdue_request
              extend_overdue_request(@booking)
            when :payment_overdue
              extend_payment_overdue(@booking)
            end
          end

          def allowed?
            @booking.deadline&.extendable?
          end

          def button_options
            super.merge(
              variant: 'secondary'
            )
          end

          private

          def new_deadline_at
            @booking.organisation.long_deadline.from_now
          end

          def extend_provisional_request(booking)
            return booking.errors.add(:deadline, :not_extendable) if new_deadline_at > booking.occupancy.begins_at

            booking.deadline.extend_until(new_deadline_at)
          end

          def extend_overdue_request(booking)
            transition_to = booking.agent_booking? ? :booking_agent_request : :provisional_request
            booking.state_machine.transition_to(transition_to)
            booking.deadline.extend_until(new_deadline_at)
          end

          def extend_payment_overdue(booking)
            booking.state_machine.transition_to(:payment_due)
            booking.deadline.extend_until(new_deadline_at)
          end
        end
      end
    end
  end
end
