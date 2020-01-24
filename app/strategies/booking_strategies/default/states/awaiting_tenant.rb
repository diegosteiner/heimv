module BookingStrategies
  class Default
    module States
      class AwaitingTenant < BookingStrategy::State
        def checklist
          []
        end

        def self.to_sym
          :awaiting_tenant
        end

        def relevant_time
          booking.deadline&.at
        end
      end
    end
  end
end
