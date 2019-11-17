module BookingStrategies
  class Default
    module Actions
      module Public
        class CommitBookingAgentRequest < CommitRequest
          def call!
            if booking.agent_booking.email.blank?
              booking.agent_booking.errors.add(:email, :blank)
            else
              booking.update(committed_request: true)
            end
          end

          def allowed?
            booking.agent_booking&.booking_agent_responsible? &&
              booking.state_machine.in_state?(:booking_agent_request)
          end

          def booking
            context.fetch(:booking)
          end
        end
      end
    end
  end
end
