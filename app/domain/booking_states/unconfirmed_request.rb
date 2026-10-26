# frozen_string_literal: true

module BookingStates
  class UnconfirmedRequest < Base
    use_mail_template(:unconfirmed_request_notification, context: %i[booking])

    def checklist
      []
    end

    def self.to_sym
      :unconfirmed_request
    end

    infer_transition(to: :expired_request) do |booking|
      booking.deadline&.expired?
    end

    infer_transition(to: :open_request) do |booking|
      booking.valid?(:public_update) || booking.agent_booking.present?
    end

    after_transition do |booking|
      booking.conflict_type_pending!
      booking.create_deadline(at: :unconfirmed_request_deadline,
                              remarks: booking.booking_state.t(:label))
      MailTemplate.use(:unconfirmed_request_notification, booking, to: :tenant, &:autodeliver!)
    end

    guard_transition do |booking|
      booking.organisation.booking_state_settings.enable_waitlist || !booking.conflict?(assuming: :tentative)
    end

    def relevant_time
      booking.deadline&.at
    end
  end
end
