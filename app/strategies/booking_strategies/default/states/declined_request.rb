# frozen_string_literal: true

module BookingStrategies
  class Default
    module States
      class DeclinedRequest < BookingStrategy::State
        def checklist
          []
        end

        def self.to_sym
          :declined_request
        end

        def relevant_time; end
      end
    end
  end
end
