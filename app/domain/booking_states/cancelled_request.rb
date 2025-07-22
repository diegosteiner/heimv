# frozen_string_literal: true

module BookingStates
  class CancelledRequest < Base
    use_mail_template(:cancelled_request_notification, context: %i[booking])
    use_mail_template(:manage_cancelled_request_notification, context: %i[booking])

    def checklist
      []
    end

    def self.to_sym
      :cancelled_request
    end

    after_transition do |booking|
      booking.free!
      booking.deadline&.clear!
      booking.conclude
      MailTemplate.use(:manage_cancelled_request_notification, booking, to: :administration, &:autodeliver!)
      MailTemplate.use(:cancelled_request_notification, booking,
                       to: booking.agent_booking ? :booking_agent : :tenant, &:autodeliver!)

      booking.conflicting_bookings.each(&:apply_transitions)
    end
  end
end
