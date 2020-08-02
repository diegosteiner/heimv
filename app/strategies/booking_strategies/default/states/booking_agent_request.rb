# frozen_string_literal: true

module BookingStrategies
  class Default
    module States
      class BookingAgentRequest < BookingStrategy::State
        def checklist
          []
        end

        def self.to_sym
          :booking_agent_request
        end

        def relevant_time
          booking.deadline&.at
        end
      end
    end
  end
end
