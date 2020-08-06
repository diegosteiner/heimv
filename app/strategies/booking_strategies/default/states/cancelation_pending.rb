# frozen_string_literal: true

module BookingStrategies
  class Default
    module States
      class CancelationPending < BookingStrategy::State
        def checklist
          []
        end

        def self.to_sym
          :cancelation_pending
        end

        def relevant_time; end
      end
    end
  end
end
