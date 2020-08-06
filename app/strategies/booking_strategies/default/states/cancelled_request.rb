# frozen_string_literal: true

module BookingStrategies
  class Default
    module States
      class CancelledRequest < BookingStrategy::State
        def checklist
          []
        end

        def self.to_sym
          :cancelled_request
        end

        def relevant_time; end
      end
    end
  end
end
