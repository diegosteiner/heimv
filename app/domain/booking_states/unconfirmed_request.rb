# frozen_string_literal: true

module BookingStates
  class UnconfirmedRequest < Base
    RichTextTemplate.require_template(:unconfirmed_request_notification, context: %i[booking], required_by: self)

    def checklist
      []
    end

    def self.to_sym
      :unconfirmed_request
    end

    # infer_transition(to: :declined_request, &:deadline_exceeded?)
    infer_transition(to: :open_request) do |booking|
      booking.valid?(:public_update) || booking.agent_booking?
    end

    after_transition do |booking|
      booking.deadline&.clear
      booking.deadlines.create(length: booking.organisation.settings.fetch(:unconfirmed_request_deadline, 3.days),
                               remarks: booking.booking_state.t(:label))
      booking.occupancy.tentative!
      booking.notifications.new(from_template: :unconfirmed_request_notification, addressed_to: :tenant).deliver
    end

    def relevant_time
      booking.deadline&.at
    end
  end
end
