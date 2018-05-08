module BookingStrategy
  module Base
    class StateMachine
      TRANSITION_CLASS = BookingTransition

      include Statesman::Machine
      include Automator

      def initialize(booking)
        super(booking, transition_class: TRANSITION_CLASS)
      end
    end
  end
end
