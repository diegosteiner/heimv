# frozen_string_literal: true

module BookingActions
  module Manage
    class SkipInvoice < BookingActions::Base
      def call!
        Result.new ok: booking.update(transition_to: :completed)
      end

      def allowed?
        booking.can_transition_to?(:completed) && booking.booking_flow.in_state?(:past) && booking.invoices.unsent.none?
      end

      def booking
        context.fetch(:booking)
      end
    end
  end
end
