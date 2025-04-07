# frozen_string_literal: true

module BookingActions
  class Accept < Base
    def invoke!(current_user: nil)
      Result.new success: booking.update(transition_to:)
    end

    def invokable?(current_user: nil)
      booking.in_state?(:open_request) && booking.can_transition_to?(transition_to)
    end

    def invokable_with
      { variant: :success } if invokable?
    end

    def transition_to
      if booking.can_transition_to?(:booking_agent_request)
        :booking_agent_request
      elsif booking.committed_request
        :definitive_request
      else
        :provisional_request
      end
    end
  end
end
