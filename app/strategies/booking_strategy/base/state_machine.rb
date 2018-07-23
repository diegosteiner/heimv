module BookingStrategy
  class Base
    class StateMachine
      TRANSITION_CLASS = BookingTransition

      include Statesman::Machine
      include StateMachineAutomator

      def initialize(booking)
        super(booking, transition_class: TRANSITION_CLASS)
      end
    end
  end
end
