# frozen_string_literal: true

module BookingStates
  class ProvisionalRequest < Base
    RichTextTemplate.require_template(:provisional_request_notification, context: %i[booking], required_by: self)

    def checklist
      []
    end

    def self.to_sym
      :provisional_request
    end

    after_transition do |booking|
      booking.deadline&.clear
      booking.deadlines.create(at: booking.organisation.long_deadline.from_now,
                               postponable_for: booking.organisation.short_deadline,
                               remarks: booking.booking_state.t(:label))
    end

    after_transition do |booking|
      booking.notifications.new(from_template: :provisional_request_notification, addressed_to: :tenant).deliver
      booking.occupancy.tentative!
      booking.update!(timeframe_locked: true)
    end

    infer_transition(to: :overdue_request, &:deadline_exceeded?)
    infer_transition(to: :definitive_request, &:committed_request)

    def relevant_time
      booking.deadline&.at
    end
  end
end