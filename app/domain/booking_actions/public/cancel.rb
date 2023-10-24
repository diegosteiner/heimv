# frozen_string_literal: true

module BookingActions
  module Public
    class Cancel < BookingActions::Base
      def call!
        booking.errors.clear
        transition_to = if booking.can_transition_to?(:declined_request)
                          :declined_request
                        elsif booking.can_transition_to?(:cancelation_pending)
                          :cancelation_pending
                        end
        Result.new ok: booking.update(transition_to: transition_to)
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
