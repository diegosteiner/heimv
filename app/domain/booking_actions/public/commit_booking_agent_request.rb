# frozen_string_literal: true

module BookingActions
  module Public
    class CommitBookingAgentRequest < CommitRequest
      def invoke!
        Result.new success: booking.update(committed_request: true)
      end

      def allowed?
        agent_booking&.booking_agent_responsible? &&
          agent_booking.booking&.booking_flow&.in_state?(:booking_agent_request)
      end

      delegate :agent_booking, to: :booking
    end
  end
end
