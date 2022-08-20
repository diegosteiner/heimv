# frozen_string_literal: true

module BookingActions
  module Manage
    class Cancel < BookingActions::Base
      def call!
        booking.errors.clear
        booking.update(transition_to: :declined_request) if booking.can_transition_to?(:declined_request)
        booking.update(transition_to: :cancelation_pending) if booking.can_transition_to?(:cancelation_pending)
      end

      def allowed?
        booking.can_transition_to?(:declined_request) ||
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
