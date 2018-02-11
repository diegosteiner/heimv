module BookingStrategy
  module Base
    class StateMachine
      include Statesman::Machine
      PREFERED_TRANSITIONS = {}.freeze
      PUBLIC_TRANSITIONS = [].freeze

      state :initial, initial: true

      def prefered_transition
        self.class::PREFERED_TRANSITIONS.with_indifferent_access.fetch(current_state, nil)
      end

      def allowed_public_transitions
        allowed_transitions & self.class::PUBLIC_TRANSITIONS
      end

      def automatic
        transitions = select_callbacks_for(self.class.callbacks[:automatic], from: current_state)
        transitions.any? do |automatic_transition|
          transition_to(automatic_transition.to) if automatic_transition.call
        end
      end

      class << self
        def automatic_transition(options = {}, &block)
          callbacks[:automatic] ||= []
          add_callback(callback_type: :automatic, callback_class: Statesman::Callback,
                       from: options[:from], to: options[:to], &block)
        end
      end
    end
  end
end
