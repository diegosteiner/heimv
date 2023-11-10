# frozen_string_literal: true

module BookingStates
  class UpcomingSoon < Base
    templates << MailTemplate.define(:upcoming_soon_notification, context: %i[booking], optional: true)
    templates << MailTemplate.define(:operator_upcoming_soon_notification, context: %i[booking], optional: true)

    def checklist
      []
    end

    def invoice_type
      Invoices::Deposit
    end

    def responsibilities
      %i[home_handover home_return]
    end

    def self.to_sym
      :upcoming_soon
    end

    after_transition do |booking|
      booking.occupied! if occupied_occupancy_state?(booking)
    end

    after_transition do |booking|
      booking.responsibilities.slice(:home_handover, :home_return).values.uniq.each do |operator|
        next if operator.email.blank?

        booking.notifications.new(template: :operator_upcoming_soon_notification, to: operator, &:deliver)
      end
    end

    after_transition do |booking|
      MailTemplate.use(:upcoming_soon_notification, booking, to: :tenant, attach: :last_infos, &:deliver)
    end

    infer_transition(to: :active) do |booking|
      booking.today? || booking.past?
    end

    def relevant_time
      booking.begins_at
    end
  end
end
