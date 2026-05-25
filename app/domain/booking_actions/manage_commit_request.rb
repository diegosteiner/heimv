# frozen_string_literal: true

module BookingActions
  class ManageCommitRequest < CommitRequest
    def invokable?(current_user: nil)
      !booking.committed_request && booking.in_state?(:provisional_request, :booking_agent_request, :waitlisted_request)
    end
  end
end
