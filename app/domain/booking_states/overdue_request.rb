# frozen_string_literal: true

module BookingStates
  class OverdueRequest < Base
    MailTemplate.define(:overdue_request_notification, context: %i[booking], optional: true)

    def checklist
      []
    end

    def invoice_type
      Invoices::Deposit
    end

    def self.to_sym
      :overdue_request
    end

    after_transition do |booking|
      booking.deadline&.clear
      length = booking.organisation.settings.overdue_request_deadline
      booking.deadlines.create(length:, remarks: booking.booking_state.t(:label)) unless length.negative?
      booking.notifications.new(template: :overdue_request_notification, to: booking.tenant)&.deliver
    end

    infer_transition(to: :definitive_request) do |booking|
      booking.committed_request
    end

    infer_transition(to: :declined_request) do |booking|
      booking.deadline_exceeded? && booking.agent_booking.blank?
    end

    def relevant_time
      booking.deadline&.at
    end
  end
end
