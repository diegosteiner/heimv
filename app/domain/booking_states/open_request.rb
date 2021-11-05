# frozen_string_literal: true

module BookingStates
  class OpenRequest < Base
    RichTextTemplate.require_template(:manage_new_booking_notification, context: %i[booking], required_by: self)
    RichTextTemplate.require_template(:open_request_notification, context: %i[booking], required_by: self)

    def checklist
      []
    end

    def self.to_sym
      :open_request
    end

    after_transition do |booking|
      booking.deadline&.clear
      responsibility = OperatorResponsibilityService.new(booking).assign(:administration).first
      booking.notifications.new(from_template: :manage_new_booking_notification,
                                to: responsibility&.operator || booking.organisation).deliver
      if booking.agent_booking?
        # booking.notifications.new(from_template: :open_booking_agent_request_notification,
        # to: booking.agent_booking.booking_agent).deliver
      else
        booking.notifications.new(from_template: :open_request_notification, to: booking.tenant).deliver
      end
    end

    # infer_transition(from: :open_request, to: :provisional_request) do |booking|
    #   !booking.tenant&.reservations_allowed
    # end

    def relevant_time
      booking.created_at
    end
  end
end
