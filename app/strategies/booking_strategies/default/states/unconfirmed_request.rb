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

        def self.successors
          %i[cancelled_request declined_request open_request]
        end

        # infer_transition(to: :declined_request, &:deadline_exceeded?)
        infer_transition(to: :open_request) do |booking|
          booking.valid?(:public_update) || booking.agent_booking?
        end

        after_transition do |booking|
          booking.deadline&.clear
          booking.deadlines.create(at: booking.organisation.short_deadline.from_now, remarks: booking.state)
          booking.occupancy.tentative!
          booking.notifications.new(from_template: :unconfirmed_request, addressed_to: :tenant).deliver
        end

        def relevant_time
          booking.created_at
        end
      end
    end
  end
end
