# frozen_string_literal: true

module BookingStates
  class Upcoming < Base
    templates << MailTemplate.define(:upcoming_notification, context: %i[booking])
    templates << MailTemplate.define(:operator_upcoming_notification, context: %i[booking])

    def checklist
      []
    end

    def self.to_sym
      :upcoming
    end

    def invoice_type
      Invoices::Deposit
    end

    def self.hidden
      true
    end

    def roles
      %i[home_handover home_return]
    end

    after_transition do |booking|
      booking.occupied! if occupied_occupancy_state?(booking)
    end

    after_transition do |booking|
      booking.deadline&.clear
      MailTemplate.use(:upcoming_notification, booking, to: :tenant, &:deliver)
      MailTemplate.use(:operator_upcoming_notification, booking, to: :home_handover, &:deliver)
      MailTemplate.use(:operator_upcoming_notification, booking, to: :home_return, &:deliver)
    end

    infer_transition(to: :upcoming_soon) do |booking|
      booking.organisation.settings.upcoming_soon_window.from_now > booking.begins_at
    end

    def relevant_time
      booking.begins_at
    end
  end
end
