# frozen_string_literal: true

module BookingStates
  class CancelledRequest < Base
    use_mail_template(:cancelled_request_notification, context: %i[booking])
    use_mail_template(:manage_cancelled_request_notification, context: %i[booking])

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
      MailTemplate.use(:manage_cancelled_request_notification, booking, to: :administration, &:autodeliver!)
      MailTemplate.use(:cancelled_request_notification, booking,
                       to: booking.agent_booking ? :booking_agent : :tenant, &:autodeliver!)
    end

    def relevant_time; end

    def self.hidden
      true
    end
  end
end
