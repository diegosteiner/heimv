# frozen_string_literal: true

module BookingStates
  class UpcomingSoon < Base
    use_mail_template(:upcoming_soon_notification, context: %i[booking], optional: true)
    use_mail_template(:operator_upcoming_soon_notification, context: %i[booking], optional: true)

    def checklist
      []
    end

    def invoice_type
      Invoices::Deposit
    end

    def roles
      %i[home_handover home_return]
    end

    def self.to_sym
      :upcoming_soon
    end

    after_transition do |booking|
      booking.occupied! if occupied_booking_state?(booking)
      Notification.dedup(booking, to: %i[administration home_handover home_return]) do |to|
        MailTemplate.use(:operator_upcoming_soon_notification, booking, to:, &:autodeliver!)
      end
      MailTemplate.use(:upcoming_soon_notification, booking, to: :tenant, &:autodeliver!)
    end

    infer_transition(to: :active) do |booking|
      booking.today? || booking.past?
    end

    def relevant_time
      booking.begins_at
    end
  end
end
