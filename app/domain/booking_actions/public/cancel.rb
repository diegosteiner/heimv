# frozen_string_literal: true

module BookingActions
  module Public
    class Cancel < BookingActions::Base
      def invoke!
        booking.reload
        transition_to = if booking.can_transition_to?(:cancelled_request)
                          :cancelled_request
                        elsif booking.can_transition_to?(:cancelation_pending)
                          :cancelation_pending
                        end
        Result.new success: booking.update(transition_to:)
      end

      def allowed?
        booking.can_transition_to?(:cancelled_request) ||
          booking.can_transition_to?(:cancelation_pending)
      end

      def variant
        :danger
      end

      def confirm
        I18n.t(:confirm)
      end
    end
  end
end
