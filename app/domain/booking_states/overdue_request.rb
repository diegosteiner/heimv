# frozen_string_literal: true

module BookingStates
  class OverdueRequest < Base
    RichTextTemplate.require_template(:overdue_request_notification, context: %i[booking], required_by: self,
                                                                     optional: true)

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
      booking.deadlines.create(length: booking.organisation.settings.overdue_request_deadline,
                               remarks: booking.booking_state.t(:label))
      booking.notifications.new(template: :overdue_request_notification, to: booking.tenant)&.deliver
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
