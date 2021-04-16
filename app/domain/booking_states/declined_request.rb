# frozen_string_literal: true

module BookingStates
  class DeclinedRequest < Base
    RichTextTemplate.require_template(:declined_request_notification, %i[booking], self)

    def checklist
      []
    end

    def self.to_sym
      :declined_request
    end

    after_transition do |booking|
      booking.occupancy.free!
      booking.cancellation_reason ||= t('deadline_exceeded') if booking.deadline_exceeded?
      booking.concluded!
      booking.deadline&.clear
      addressed_to = booking.agent_booking? ? :booking_agent : :tenant
      booking.notifications.new(from_template: :declined_request_notification, addressed_to: addressed_to).deliver
    end

    def relevant_time; end
  end
end
