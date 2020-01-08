module BookingStrategies
  class Default
    module States
      class ProvisionalRequest < BookingStrategy::State
        def checklist
          []
        end

        def self.to_sym
          :provisional_request
        end

        def relevant_time
          booking.deadline&.at
        end
      end
    end
  end
end
