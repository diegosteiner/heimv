# frozen_string_literal: true

module BookingActions
  module Manage
    class Accept < BookingActions::Base
      def invoke!
        Result.new success: booking.update(transition_to:)
      end

      def allowed?
        booking.in_state?(:open_request) && booking.can_transition_to?(transition_to)
      end

      def variant
        :success
      end

      protected

      def transition_to
        if booking.agent_booking.present?
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
