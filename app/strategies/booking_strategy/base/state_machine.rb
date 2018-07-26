module BookingStrategy
  class Base
    class StateMachine
      OBJECT_CLASS = Booking

      include Statesman::Machine

      def initialize(booking)
        super(booking, transition_class: OBJECT_CLASS.transition_class)
      end
    end
  end
end
