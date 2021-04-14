# frozen_string_literal: true

module BookingActions
  module Manage
    class Cancel < BookingActions::Base
      def call!
        booking.errors.clear
        booking.booking_flow.yield_self do |booking_flow|
          if booking_flow.can_transition_to?(:declined_request)
            booking_flow.transition_to(:declined_request)
          elsif booking_flow.can_transition_to?(:cancelation_pending)
            booking_flow.transition_to(:cancelation_pending)
          end
        end
      end

      def allowed?
        booking.booking_flow.can_transition_to?(:declined_request) ||
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
