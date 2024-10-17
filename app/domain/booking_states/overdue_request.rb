# frozen_string_literal: true

module BookingStates
  class OverdueRequest < Base
    templates << MailTemplate.define(:overdue_request_notification, context: %i[booking], optional: true)

    def checklist
      []
    end

    def invoice_type
      Invoices::Deposit
    end

    def self.to_sym
      :overdue_request
    end

    def editable
      true
    end

    after_transition do |booking|
      booking.deadline&.clear
      length = booking.organisation.settings.overdue_request_deadline
      booking.deadlines.create(length:, remarks: booking.booking_state.t(:label)) unless length.negative?
      MailTemplate.use(:overdue_request_notification, booking, to: :tenant, &:autodeliver!)
    end

    infer_transition(to: :definitive_request) do |booking|
      booking.committed_request && (booking&.tenant&.valid?(:public_update) || !booking.agent_booking)
    end

    infer_transition(to: :declined_request) do |booking|
      booking.deadline_exceeded? && !booking.agent_booking
    end

    def relevant_time
      booking.deadline&.at
    end
  end
end
