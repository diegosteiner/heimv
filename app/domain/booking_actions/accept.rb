# frozen_string_literal: true

module BookingActions
  class Accept < Base
    def invoke!(current_user: nil)
      Result.new success: booking.update(transition_to:)
    end

    def invokable?(current_user: nil)
      booking.in_state?(:open_request, :waitlisted_request) && transition_to.present?
    end

    def invokable_with(current_user: nil)
      { variant: :success } if invokable?(current_user:)
    end

    def transition_to
      %i[booking_agent_request definitive_request provisional_request].find do
        booking.can_transition_to?(it)
      end
    end
  end
end
