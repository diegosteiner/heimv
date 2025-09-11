# frozen_string_literal: true

module BookingActions
  class PutOnWaitlist < Base
    def invoke!(current_user: nil)
      booking.update!(transition_to: :waitlisted_request)
      Result.success
    end

    def invokable?(current_user: nil)
      booking.can_transition_to?(:waitlisted_request)
    end

    def invokable_with(current_user: nil)
      { variant: :warning, label: translate(:label) } if invokable?(current_user:)
    end
  end
end
