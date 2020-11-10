# frozen_string_literal: true

module BookingStrategies
  class Default
    module States
      class ProvisionalRequest < BookingStrategy::State
        def checklist
          []
        end

        def self.to_sym
          :provisional_request
        end

        def self.successors
          %i[definitive_request overdue_request cancelled_request declined_request]
        end

        after_transition do |booking|
          booking.deadline&.clear
          booking.deadlines.create(at: booking.organisation.long_deadline.from_now,
                                   postponable_for: booking.organisation.short_deadline,
                                   remarks: booking.state)
        end

        after_transition do |booking, transition|
          booking.notifications.new(from_template: transition.to_state.to_s, addressed_to: :tenant).deliver
          booking.occupancy.tentative!
          booking.lock_timeframe!
        end

        infer_transition(to: :overdue_request, &:deadline_exceeded?)
        infer_transition(to: :definitive_request, &:committed_request)

        def relevant_time
          booking.deadline&.at
        end
      end
    end
  end
end
