# frozen_string_literal: true

module BookingActions
  class ClearWaitlist < Base
    def invoke(current_user: nil)
      waitlisted_requests.all? do |booking|
        booking.update!(occupancy_status: :void, transition_to: :declined_request,
                        cancellation_reason: translate(:cancellation_reason))
      end
      Result.success
    end

    def invokable?(current_user: nil)
      booking.status_occupied? && waitlisted_requests.any?
    end

    def invokable_with(current_user: nil)
      { variant: :danger, confirm: I18n.t(:confirm) } if invokable?(current_user:)
    end

    def waitlisted_requests
      booking.conflicting(assuming: :any).where(booking_state_cache: :waitlisted_request)
    end
  end
end
