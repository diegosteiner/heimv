# frozen_string_literal: true

module BookingStates
  class ProvisionalRequest < Base
    RichTextTemplate.require_template(:provisional_request_notification, context: %i[booking], required_by: self)

    def checklist
      []
    end

    def invoice_type
      Invoices::Deposit
    end

    def self.to_sym
      :provisional_request
    end

    after_transition do |booking|
      booking.deadline&.clear
      booking.deadlines.create(length: booking.organisation.settings.provisional_request_deadline,
                               postponable_for: booking.organisation.settings.deadline_postponable_for,
                               remarks: booking.booking_state.t(:label))
    end

    after_transition do |booking|
      booking.notifications.new(template: :provisional_request_notification, to: booking.tenant).deliver
      booking.occupancy.tentative!
    end

    infer_transition(to: :overdue_request, &:deadline_exceeded?)
    infer_transition(to: :definitive_request, &:committed_request)

    def relevant_time
      booking.deadline&.at
    end
  end
end
