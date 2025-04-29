# frozen_string_literal: true

module BookingStates
  class Upcoming < Base
    use_mail_template(:upcoming_notification, context: %i[booking])
    use_mail_template(:operator_upcoming_notification, context: %i[booking], optiona: true)

    def checklist
      []
    end

    def self.to_sym
      :upcoming
    end

    def roles
      %i[home_handover home_return]
    end

    after_transition do |booking|
      booking.occupied! if occupied_booking_state?(booking)
    end

    after_transition do |booking|
      booking.deadline&.clear!
      MailTemplate.use(:upcoming_notification, booking, to: :tenant, &:autodeliver!)
      Notification.dedup(booking, to: %i[home_handover home_return]) do |to|
        MailTemplate.use(:operator_upcoming_notification, booking, to:, &:autodeliver!)
      end
    end

    infer_transition(to: :upcoming_soon) do |booking|
      booking.organisation.settings.upcoming_soon_window.from_now > booking.begins_at
    end

    def relevant_time
      booking.begins_at
    end
  end
end
