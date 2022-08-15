# frozen_string_literal: true

module BookingActions
  module Public
    class CommitRequest < BookingActions::Base
      def call!
        booking.update(committed_request: true) && booking.transition_to
      end

      def allowed?
        booking.valid?(:public_update) &&
          booking.tenant&.complete? &&
          booking.booking_flow.in_state?(:provisional_request, :overdue_request) &&
          !booking.committed_request
      end

      def button_options
        super.merge(
          variant: 'primary'
        )
      end

      def booking
        context.fetch(:booking)
      end
    end
  end
end
