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

        before_transition do |booking|
          booking.lock_timeframe!
          booking.lock_editable!
          booking.occupancy.free!
        end

        after_transition do |booking|
          booking.deadline&.clear
          booking.concluded!
          addressed_to = booking.agent_booking? ? :booking_agent : :tenant
          booking.notifications.new(from_template: :declined_request, addressed_to: addressed_to).deliver
        end

        def relevant_time; end
      end
    end
  end
end
