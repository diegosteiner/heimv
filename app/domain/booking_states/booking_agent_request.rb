# frozen_string_literal: true

module BookingStates
  class BookingAgentRequest < Base
    RichTextTemplate.require_template(:booking_agent_request_notification, context: %i[booking], required_by: self)

    def checklist
      []
    end

    def invoice_type
      Invoices::Deposit
    end

    def self.to_sym
      :booking_agent_request
    end

    guard_transition do |booking|
      booking.agent_booking.present?
    end

    after_transition do |booking|
      booking.deadline&.clear
      booking.deadlines.create(at: booking.booking_agent.request_deadline_minutes.minutes.from_now,
                               postponable_for: booking.organisation.settings.deadline_postponable_for,
                               remarks: booking.booking_state.t(:label))
    end

    after_transition do |booking|
      booking.notifications.new(template: :booking_agent_request_notification,
                                to: booking.agent_booking.booking_agent).deliver
      booking.tentative!
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
