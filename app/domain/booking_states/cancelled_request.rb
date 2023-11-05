# frozen_string_literal: true

module BookingStates
  class CancelledRequest < Base
    RichTextTemplate.define(:cancelled_request_notification, template_context: %i[booking], required_by: self)

    def checklist
      []
    end

    def invoice_type
      Invoices::Invoice
    end

    def self.to_sym
      :cancelled_request
    end

    after_transition do |booking|
      booking.free!
      booking.conclude
      booking.deadline&.clear
      booking.notifications.new(template: :cancelled_request_notification,
                                to: booking.agent_booking&.booking_agent || booking.tenant).deliver
    end

    def relevant_time; end

    def self.hidden
      true
    end
  end
end
