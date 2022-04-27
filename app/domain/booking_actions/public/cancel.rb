# frozen_string_literal: true

module BookingActions
  module Public
    class Cancel < BookingActions::Base
      def call!
        booking.errors.clear
        booking.booking_flow.then do |booking_flow|
          if booking_flow.can_transition_to?(:cancelled_request)
            booking_flow.transition_to(:cancelled_request)
          elsif booking_flow.can_transition_to?(:cancelation_pending)
            booking_flow.transition_to(:cancelation_pending)
          end
        end
      end

      def allowed?
        booking.booking_flow.can_transition_to?(:cancelled_request) ||
          booking.booking_flow.can_transition_to?(:cancelation_pending)
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
