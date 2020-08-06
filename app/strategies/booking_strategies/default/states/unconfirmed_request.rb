# frozen_string_literal: true

module BookingStrategies
  class Default
    module States
      class UnconfirmedRequest < BookingStrategy::State
        def checklist
          []
        end

        def self.to_sym
          :unconfirmed_request
        end

        def relevant_time
          booking.created_at
        end
      end
    end
  end
end
