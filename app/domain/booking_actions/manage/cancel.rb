# frozen_string_literal: true

module BookingActions
  module Manage
    class Cancel < BookingAction
      def call!
        booking.errors.clear
        booking.state_machine.yield_self do |state_machine|
          if state_machine.can_transition_to?(:declined_request)
            state_machine.transition_to(:declined_request)
          elsif state_machine.can_transition_to?(:cancelation_pending)
            state_machine.transition_to(:cancelation_pending)
          end
        end
      end

      def allowed?
        booking.state_machine.can_transition_to?(:declined_request) ||
          booking.state_machine.can_transition_to?(:cancelation_pending)
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
