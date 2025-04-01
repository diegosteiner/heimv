# frozen_string_literal: true

module BookingStates
  class DeclinedRequest < Base
    use_mail_template(:declined_request_notification, context: %i[booking])

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
      booking.cancellation_reason ||= t('deadline_exceeded') if booking.deadline&.exceeded?
      booking.conclude
      booking.deadline&.clear!
      MailTemplate.use(:declined_request_notification, booking,
                       to: booking.agent_booking ? :booking_agent : :tenant, &:autodeliver!)
    end

    def relevant_time; end
  end
end
