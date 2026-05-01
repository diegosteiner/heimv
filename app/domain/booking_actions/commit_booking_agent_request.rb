# frozen_string_literal: true

module BookingActions
  class CommitBookingAgentRequest < Base
    def invoke!(current_user: nil)
      booking.assign_attributes(committed_request: true)
      Result.new success: booking.save(context: :agent_update)
    end

    def invokable?(current_user: nil)
      agent_booking&.booking_agent_responsible? && !booking&.committed_request_in_database &&
        booking.valid_with_attributes?(context: :agent_update, committed_request: true)
    end

    def invokable_with(current_user: nil)
      if booking.in_state?(:booking_agent_request) && agent_booking&.booking_agent_responsible? &&
         !booking&.committed_request_in_database
        { confirm: translate(:confirm) }
      end
    end

    delegate :agent_booking, to: :booking
  end
end
