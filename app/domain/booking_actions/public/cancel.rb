# frozen_string_literal: true

module BookingActions
  module Public
    class Cancel < BookingActions::Base
      def call!
        booking.errors.clear
        if booking.can_transition_to?(:cancelled_request)
          booking.transition_to(:cancelled_request, metadata: { current_user: context[:current_user] })
        elsif booking.can_transition_to?(:cancelation_pending)
          booking.transition_to(:cancelation_pending, metadata: { current_user: context[:current_user] })
        end
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
