# frozen_string_literal: true

module BookingStates
  class OverdueRequest < Base
    RichTextTemplate.require_template(:overdue_request_notification, %i[booking], self)

    def checklist
      []
    end

    def self.to_sym
      :overdue_request
    end

    after_transition do |booking|
      booking.deadline&.clear
      booking.deadlines.create(at: booking.organisation.short_deadline.from_now,
                               remarks: booking.booking_state.t(:label))
      booking.notifications.new(from_template: :overdue_request_notification, addressed_to: :tenant)&.deliver
    end

    infer_transition(to: :definitive_request, &:committed_request)
    infer_transition(to: :declined_request) do |booking|
      booking.deadline_exceeded? && !booking.agent_booking?
    end

    def relevant_time
      booking.deadline&.at
    end
  end
end
