# frozen_string_literal: true

module BookingStates
  class BookingAgentRequest < Base
    use_mail_template(:booking_agent_request_notification, context: %i[booking])

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
      booking.create_deadline(at: booking.booking_agent.request_deadline_minutes.minutes.from_now,
                              postponable_for: booking.organisation.deadline_settings.deadline_postponable_for,
                              remarks: booking.booking_state.t(:label))
    end

    after_transition do |booking|
      MailTemplate.use(:booking_agent_request_notification, booking, to: :booking_agent, &:autodeliver!)
      booking.tentative!
    end

    infer_transition(to: :cancelled_request) do |booking|
      booking.deadline&.exceeded?
    end

    infer_transition(to: :awaiting_tenant) do |booking|
      booking.agent_booking.valid? && booking.committed_request
    end

    def relevant_time
      booking.deadline&.at
    end
  end
end
