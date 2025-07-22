# frozen_string_literal: true

module BookingStates
  class DeclinedRequest < Base
    use_mail_template(:declined_request_notification, context: %i[booking])

    def checklist
      []
    end

    def self.to_sym
      :declined_request
    end

    after_transition do |booking|
      booking.free!
      booking.conclude
      booking.deadline&.clear!
      MailTemplate.use(:declined_request_notification, booking,
                       to: booking.agent_booking ? :booking_agent : :tenant, &:autodeliver!)

      booking.conflicting_bookings.each(&:apply_transitions)
    end

    def relevant_time; end
  end
end
