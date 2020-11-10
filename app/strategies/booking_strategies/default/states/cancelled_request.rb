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

        after_transition do |booking|
          booking.concluded!
          booking.deadline&.clear
          addressed_to = booking.agent_booking? ? :booking_agent : :tenant
          booking.notifications.new(from_template: :cancelled_request, addressed_to: addressed_to).deliver
        end

        before_transition do |booking|
          booking.lock_timeframe!
          booking.lock_editable!
          booking.occupancy.free!
        end

        def relevant_time; end
      end
    end
  end
end
