# frozen_string_literal: true

module BookingStrategies
  class Default
    module States
      class OpenRequest < BookingStrategy::State
        def checklist
          []
        end

        def self.to_sym
          :open_request
        end

        def relevant_time
          booking.created_at
        end
      end
    end
  end
end
