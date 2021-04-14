# frozen_string_literal: true

module BookingActions
  module Manage
    class Accept < BookingActions::Base
      def call!
        booking.booking_flow.transition_to(transition_to)
      end

      def allowed?
        booking.booking_flow.yield_self do |booking_flow|
          booking_flow.in_state?(:open_request) && booking_flow.can_transition_to?(transition_to)
        end
      end

      def button_options
        super.merge(
          variant: 'success'
        )
      end

      def booking
        context.fetch(:booking)
      end

      protected

      def transition_to
        if booking.agent_booking?
          :booking_agent_request
        elsif booking.committed_request
          :definitive_request
        else
          :provisional_request
        end
      end
    end
  end
end
