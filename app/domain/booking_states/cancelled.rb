# frozen_string_literal: true

module BookingStates
  class Cancelled < Base
    MailTemplate.define(:cancelled_notification, context: %i[booking])
    MailTemplate.define(:booking_agent_cancelled_notification, context: %i[booking])

    def checklist
      []
    end

    def invoice_type
      Invoices::Invoice
    end

    def self.to_sym
      :cancelled
    end

    def self.hidden
      true
    end

    guard_transition do |booking|
      !booking.invoices.kept.unsettled.exists?
    end

    after_transition do |booking|
      booking.free!
      booking.conclude
      booking.notifications.new(template: :cancelled_notification, to: booking.tenant).deliver
      next if booking.agent_booking.blank?

      booking.notifications.new(template: :booking_agent_cancelled_notification,
                                to: booking.agent_booking.booking_agent).deliver
    end

    def relevant_time; end
  end
end
