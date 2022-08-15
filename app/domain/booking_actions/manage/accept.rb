# frozen_string_literal: true

module BookingActions
  module Manage
    class Accept < BookingActions::Base
      def call!
        booking.transition_to(transition_to, metadata: { current_user: context[:current_user] })
      end

      def allowed?
        booking.in_state?(:open_request) && booking.can_transition_to?(transition_to)
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
