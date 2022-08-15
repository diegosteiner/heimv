# frozen_string_literal: true

module BookingActions
  module Manage
    class CommitRequest < BookingActions::Base
      def call!
        booking.update(committed_request: true) && booking.auto_transition
      end

      def allowed?
        booking.valid? &&
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
