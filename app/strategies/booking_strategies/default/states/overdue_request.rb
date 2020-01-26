module BookingStrategies
  class Default
    module States
      class OverdueRequest < BookingStrategy::State
        def checklist
          []
        end

        def self.to_sym
          :overdue_request
        end

        def relevant_time
          booking.deadline&.at
        end
      end
    end
  end
end
