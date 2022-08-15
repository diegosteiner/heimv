# frozen_string_literal: true

module BookingActions
  module Public
    class CommitBookingAgentRequest < CommitRequest
      def call!
        agent_booking.update(committed_request: true)
        agent_booking.booking.transition_to
      end

      def allowed?
        agent_booking&.booking_agent_responsible? &&
          agent_booking.booking&.booking_flow&.in_state?(:booking_agent_request)
      end

      def agent_booking
        context.fetch(:booking)&.agent_booking
      end
    end
  end
end
