module BookingStrategy
  module Base
    class StateMachine
      extend WithTemplate
      include Statesman::Machine

      def initialize(booking)
        super(booking, transition_class: Booking.transition_class)
      end
    end
  end
end
