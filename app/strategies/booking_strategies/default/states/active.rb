# frozen_string_literal: true

module BookingStrategies
  class Default
    module States
      class Active < BookingStrategy::State
        def checklist
          []
        end

        def self.to_sym
          :active
        end

        def relevant_time
          booking.occupancy.ends_at
        end
      end
    end
  end
end
