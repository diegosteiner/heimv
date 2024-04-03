# frozen_string_literal: true

module BookingActions
  module Manage
    class Cancel < BookingActions::Base
      def invoke!
        booking.errors.clear
        transition_to = if booking.can_transition_to?(:declined_request)
                          :declined_request
                        elsif booking.can_transition_to?(:cancelation_pending)
                          :cancelation_pending
                        end
        Result.new success: booking.update(transition_to:)
      end

      def allowed?
        booking.can_transition_to?(:declined_request) ||
          booking.can_transition_to?(:cancelation_pending)
      end

      def variant
        :danger
      end

      def confirm
        I18n.t(:confirm)
      end

      def booking
        context.fetch(:booking)
      end
    end
  end
end
