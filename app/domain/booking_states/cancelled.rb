# frozen_string_literal: true

module BookingStates
  class Cancelled < Base
    RichTextTemplate.require_template(:cancelled_notification, context: %i[booking], required_by: self)
    RichTextTemplate.require_template(:booking_agent_cancelled_notification, context: %i[booking], required_by: self)

    def checklist
      []
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
      booking.occupancy.free!
      booking.conclude
      booking.notifications.new(from_template: :cancelled_notification, addressed_to: :tenant).deliver
      next unless booking.agent_booking?

      booking.notifications.new(from_template: :booking_agent_cancelled_notification,
                                addressed_to: :booking_agent).deliver
    end

    def relevant_time; end
  end
end