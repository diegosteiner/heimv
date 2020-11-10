# frozen_string_literal: true

module BookingStrategies
  class Default
    module States
      class BookingAgentRequest < BookingStrategy::State
        def checklist
          []
        end

        def self.to_sym
          :booking_agent_request
        end

        def self.successors
          %i[cancelled_request declined_request awaiting_tenant overdue_request]
        end

        guard_transition do |booking|
          booking.agent_booking.present?
        end

        after_transition do |booking|
          booking.deadline&.clear
          booking.deadlines.create(at: booking.booking_agent.request_deadline_minutes.minutes.from_now,
                                   postponable_for: booking.organisation.short_deadline,
                                   remarks: booking.state)
        end

        after_transition do |booking|
          booking.notifications.new(from_template: :booking_agent_request, addressed_to: :booking_agent).deliver
          booking.occupancy.tentative!
        end

        infer_transition(to: :cancelled_request, &:deadline_exceeded?)
        infer_transition(to: :awaiting_tenant) do |booking|
          booking.agent_booking.valid? && booking.agent_booking.committed_request
        end

        def relevant_time
          booking.deadline&.at
        end
      end
    end
  end
end
