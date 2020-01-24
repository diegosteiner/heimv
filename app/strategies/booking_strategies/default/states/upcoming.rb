module BookingStrategies
  class Default
    module States
      class Upcoming < BookingStrategy::State
        def checklist
          []
        end

        def self.to_sym
          :upcoming
        end

        def relevant_time
          booking.occupancy.begins_at
        end
      end
    end
  end
end
