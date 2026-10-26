# frozen_string_literal: true

module BookingStates
  class ExpiredRequest < Base
    use_mail_template(:expired_request_notification, context: %i[booking])
    use_mail_template(:manage_expired_request_notification, context: %i[booking])
    use_mail_template(:booking_agent_expired_request_notification, context: %i[booking], optional: true)

    def checklist
      []
    end

    def self.to_sym
      :expired_request
    end

    after_transition do |booking|
      booking.cancellation_reason ||= translate(:cancellation_reason) if booking.deadline&.expired?
      booking.update!(conflict_type: :void, concluded: true)
      booking.deadline&.clear!
      MailTemplate.use(:manage_expired_request_notification, booking, to: :administration, &:autodeliver!)
      MailTemplate.use(:expired_request_notification, booking,
                       to: booking.agent_booking ? :booking_agent : :tenant, &:autodeliver!)
    end

    def relevant_time; end
  end
end
