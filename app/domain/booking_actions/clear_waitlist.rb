# frozen_string_literal: true

module BookingActions
  class ClearWaitlist < Base
    def invoke(current_user: nil)
      success = waitlisted_requests.all? do |booking|
        booking.update(transition_to: :declined_request, cancellation_reason: translate(:cancellation_reason))
      end
      Result.new(success:)
    end

    def invokable?(current_user: nil)
      booking.occupied? && waitlisted_requests.any?
    end

    def invokable_with(current_user: nil)
      { variant: :danger, confirm: I18n.t(:confirm) } if invokable?(current_user:)
    end

    def waitlisted_requests
      booking.occupancies.flat_map { it.conflicting(%i[occupied tentative]).map(&:booking) }.uniq
    end
  end
end
