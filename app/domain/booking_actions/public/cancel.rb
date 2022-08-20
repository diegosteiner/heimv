# frozen_string_literal: true

module BookingActions
  module Public
    class Cancel < BookingActions::Base
      def call!
        booking.errors.clear
        booking.update(transition_to: :cancelled_request) if booking.can_transition_to?(:cancelled_request)
        booking.update(transition_to: :cancelation_pending) if booking.can_transition_to?(:cancelation_pending)
      end

      def allowed?
        booking.can_transition_to?(:cancelled_request) ||
          booking.can_transition_to?(:cancelation_pending)
      end

      def button_options
        super.merge(
          variant: 'danger',
          data: {
            confirm: I18n.t(:confirm)
          }
        )
      end

      def booking
        context.fetch(:booking)
      end
    end
  end
end
