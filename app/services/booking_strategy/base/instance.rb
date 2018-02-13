module BookingStrategy
  module Base
    class Instance
      def initialize(booking)
        @booking = booking
      end

      def view_model
        @view_model ||= strategy::ViewModel.new(@booking)
      end

      def state_machine
        @state_machine ||= strategy::StateMachine.new(@booking, transition_class: @booking.booking_transitions.klass)
      end

      def strategy
        BookingStrategy::Base
      end
    end
  end
end
