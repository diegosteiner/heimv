# frozen_string_literal: true

module BookingActions
  class CommitBookingAgentRequest < Base
    def invoke!(current_user: nil)
      booking.assign_attributes(committed_request: true)
      Result.new success: booking.save(context: :agent_update)
    end

    def invokable?(current_user: nil)
      agent_booking&.booking_agent_responsible? && !booking&.committed_request_in_database
    end

    delegate :agent_booking, to: :booking
  end
end
