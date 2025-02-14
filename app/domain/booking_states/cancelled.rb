# frozen_string_literal: true

module BookingStates
  class Cancelled < Base
    templates << MailTemplate.define(:cancelled_notification, context: %i[booking])
    templates << MailTemplate.define(:booking_agent_cancelled_notification, context: %i[booking])

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
      !booking.invoices.unpaid.exists?
    end

    after_transition do |booking|
      booking.free!
      booking.conclude
      MailTemplate.use(:cancelled_notification, booking, to: :tenant, &:autodeliver!)
      next if booking.agent_booking.blank?

      MailTemplate.use(:booking_agent_cancelled_notification, booking, to: :booking_agent, &:autodeliver!)
    end

    def relevant_time; end
  end
end
