# frozen_string_literal: true

module BookingStates
  class OpenRequest < Base
    use_mail_template(:manage_new_booking_notification, context: %i[booking], optional: true)
    use_mail_template(:open_booking_agent_request_notification, context: %i[booking], optional: true)
    use_mail_template(:open_request_notification, context: %i[booking])

    def checklist
      []
    end

    def self.to_sym
      :open_request
    end

    guard_transition do |booking|
      (booking.agent_booking.nil? && booking.organisation.booking_state_settings.enable_waitlist) ||
        !booking.conflicting?(assuming: :tentative)
    end

    after_transition do |booking|
      booking.deadline&.clear!
      booking.status_pending!
      booking.update(concluded: false) # in case it's reinstated from declined or cancelled

      OperatorResponsibility.assign(booking, :administration, :billing)
      MailTemplate.use(:manage_new_booking_notification, booking, to: :administration, &:autodeliver!)

      if booking.agent_booking.present?
        MailTemplate.use(:open_booking_agent_request_notification, booking, to: :booking_agent, &:autodeliver!)
      else
        MailTemplate.use(:open_request_notification, booking, to: :tenant, &:autodeliver!)
      end
    end

    def relevant_time
      booking.created_at
    end
  end
end
