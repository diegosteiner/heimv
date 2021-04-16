# frozen_string_literal: true

module BookingStates
  class CancelledRequest < Base
    RichTextTemplate.require_template(:cancelled_request_notification, %i[booking], self)

    def checklist
      []
    end

    def self.to_sym
      :cancelled_request
    end

    after_transition do |booking|
      booking.occupancy.free!
      booking.concluded!
      booking.deadline&.clear
      addressed_to = booking.agent_booking? ? :booking_agent : :tenant
      booking.notifications.new(from_template: :cancelled_request_notification, addressed_to: addressed_to).deliver
    end

    def relevant_time; end

    def self.hidden
      true
    end
  end
end
