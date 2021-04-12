# frozen_string_literal: true

module BookingActions
  module Public
    class CommitBookingAgentRequest < CommitRequest
      def call!
        agent_booking.assign_attributes(committed_request: true)
        agent_booking.save_and_update_booking
      end

      def allowed?
        agent_booking&.booking_agent_responsible? &&
          agent_booking.booking&.state_machine&.in_state?(:booking_agent_request)
      end

      def agent_booking
        context.fetch(:booking)&.agent_booking
      end
    end
  end
end
