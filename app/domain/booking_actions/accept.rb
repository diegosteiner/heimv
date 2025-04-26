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
      return unless invokable?(current_user:)

      case transition_to
      when :waitlisted_request
        { variant: :warning, label: translate(:label_waitlisted_request) }
      else
        { variant: :success }
      end
    end

    def transition_to
      %i[booking_agent_request definitive_request provisional_request waitlisted_request].find do
        booking.can_transition_to?(it)
      end
    end
  end
end
