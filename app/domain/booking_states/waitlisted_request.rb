# frozen_string_literal: true

module BookingStates
  class WaitlistedRequest < Base
    use_mail_template(:waitlisted_request_notification, context: %i[booking])

    def checklist
      []
    end

    def self.to_sym
      :waitlisted_request
    end

    after_transition do |booking|
      booking.tentative!
      MailTemplate.use(:waitlisted_request_notification, booking, to: :tenant, &:autodeliver!)

      booking.conflicting_bookings.each(&:apply_transitions)
    end

    guard_transition do |booking|
      booking.organisation.booking_state_settings.enable_waitlist
    end

    def relevant_time
      booking.created_at
    end
  end
end
