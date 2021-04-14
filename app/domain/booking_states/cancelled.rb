# frozen_string_literal: true

module BookingStates
  class Cancelled < BookingState
    RichTextTemplate.require_template(:cancelled_notification, %i[booking])
    RichTextTemplate.require_template(:booking_agent_cancelled_notification, %i[booking])

    def checklist
      []
    end

    def self.to_sym
      :cancelled
    end

    guard_transition do |booking|
      !booking.invoices.unpaid.exists?
    end

    after_transition do |booking|
      booking.occupancy.free!
      booking.concluded!
      booking.notifications.new(from_template: :cancelled_notification, addressed_to: :tenant).deliver
      next unless booking.agent_booking?

      booking.notifications.new(from_template: :booking_agent_cancelled_notification,
                                addressed_to: :booking_agent).deliver
    end

    def relevant_time; end
  end
end
