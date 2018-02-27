module BookingStrategy
  module Base
    class StateMachine
      include Statesman::Machine
      include Automator

      PREFERED_TRANSITIONS = {}.freeze
      TRANSITION_CLASS = BookingTransition

      def initialize(booking)
        super(booking, transition_class: TRANSITION_CLASS)
      end

      def prefered_transition
        self.class::PREFERED_TRANSITIONS.with_indifferent_access.fetch(current_state, nil)
      end
    end
  end
end
