module BookingStrategy
  module Base
    class StateMachine
      include Statesman::Machine

      def initialize(booking)
        super(booking, transition_class: Booking.transition_class)
      end
    end
  end
end
