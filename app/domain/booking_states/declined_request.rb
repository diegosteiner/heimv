# frozen_string_literal: true

module BookingStates
  class DeclinedRequest < Base
    RichTextTemplate.require_template(:declined_request_notification, context: %i[booking], required_by: self)

    def checklist
      []
    end

    def invoice_type
      Invoices::Invoice
    end

    def self.to_sym
      :declined_request
    end

    def self.hidden
      true
    end

    after_transition do |booking|
      booking.free!
      booking.cancellation_reason ||= t('deadline_exceeded') if booking.deadline_exceeded?
      booking.conclude
      booking.deadline&.clear
      booking.notifications.new(template: :declined_request_notification,
                                to: booking.agent_booking&.booking_agent || booking.tenant).deliver
    end

    def relevant_time; end
  end
end
