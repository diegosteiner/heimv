# frozen_string_literal: true

module BookingActions
  class CommitBookingAgentRequest < Base
    def invoke!(current_user: nil)
      Result.new success: booking.update(committed_request: true)
    end

    def invokable?(current_user: nil)
      agent_booking&.booking_agent_responsible? &&
        booking&.can_transition_to?(:awaiting_tenant) &&
        booking&.booking_flow&.in_state?(:booking_agent_request)
    end

    delegate :agent_booking, to: :booking
  end
end
