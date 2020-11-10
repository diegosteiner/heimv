# frozen_string_literal: true

module BookingStrategies
  class Default
    module States
      class Cancelled < BookingStrategy::State
        def checklist
          []
        end

        def self.to_sym
          :cancelled
        end

        guard_transition do |booking|
          !booking.invoices.unpaid.exists?
        end

        before_transition do |booking|
          booking.lock_editable!
          booking.occupancy.free!
        end

        after_transition do |booking|
          booking.concluded!
          booking.notifications.new(from_template: :cancelled, addressed_to: :tenant).deliver
          next unless booking.agent_booking?

          booking.notifications.new(from_template: :booking_agent_cancelled, addressed_to: :booking_agent).deliver
        end

        def relevant_time; end
      end
    end
  end
end
