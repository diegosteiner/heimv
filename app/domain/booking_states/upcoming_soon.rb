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
      MailTemplate.use(:operator_upcoming_soon_notification, booking, to: :home_handover, &:deliver)
      MailTemplate.use(:operator_upcoming_soon_notification, booking, to: :home_return, &:deliver)
      MailTemplate.use(:upcoming_soon_notification, booking, to: :tenant, attach: :last_info_documents, &:deliver)
    end

    infer_transition(to: :active) do |booking|
      booking.today? || booking.past?
    end

    def relevant_time
      booking.begins_at
    end
  end
end
