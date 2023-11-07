# frozen_string_literal: true

module BookingStates
  class Completed < Base
    MailTemplate.define(:completed_notification, context: %i[booking], optional: true)
    def checklist
      []
    end

    def invoice_type
      Invoices::Invoice
    end

    def self.to_sym
      :completed
    end

    def self.hidden
      true
    end

    guard_transition do |booking|
      !booking.invoices.kept.unsettled.exists?
    end

    after_transition do |booking|
      booking.deadline&.clear
      booking.conclude
      booking.notifications.new(template: :completed_notification, to: booking.tenant)&.deliver
    end

    def relevant_time; end
  end
end
