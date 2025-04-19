# frozen_string_literal: true

module BookingStates
  class OpenRequest < Base
    use_mail_template(:manage_new_booking_notification, context: %i[booking])
    use_mail_template(:open_booking_agent_request_notification, context: %i[booking])
    use_mail_template(:open_request_notification, context: %i[booking])

    def checklist
      []
    end

    def self.to_sym
      :open_request
    end

    after_transition do |booking|
      booking.deadline&.clear!
      booking.tentative!
      booking.update(concluded: false) # in case it's reinstated from declined or cancelled

      OperatorResponsibility.assign(booking, :administration, :billing)
      MailTemplate.use(:manage_new_booking_notification, booking, to: :administration, &:autodeliver!)

      if booking.agent_booking.present?
        MailTemplate.use(:open_booking_agent_request_notification, booking, to: :booking_agent, &:autodeliver!)
      else
        MailTemplate.use(:open_request_notification, booking, to: :tenant, &:autodeliver!)
      end
    end

    guard_transition do |booking|
      if booking.organisation.booking_state_settings.enable_waitlist
        !booking.conflicting?
      else
        !booking.conflicting?(%i[occupied tentative])
      end
    end

    def relevant_time
      booking.created_at
    end
  end
end
