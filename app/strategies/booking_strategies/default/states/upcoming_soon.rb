# frozen_string_literal: true

module BookingStrategies
  class Default
    module States
      class UpcomingSoon < BookingStrategy::State
        def checklist
          []
        end

        def self.to_sym
          :upcoming_soon
        end

        def relevant_time
          booking.occupancy.begins_at
        end
      end
    end
  end
end
