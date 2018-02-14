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

      def allowed_transitions(public = false)
        super & self.class::PUBLIC_TRANSITIONS
      end

      def automatic
        loop do
          conditions = select_callbacks_for(self.class.callbacks[:automatic], from: current_state)
        break unless conditions.any? do |condition|
          transition_to(condition.to) if condition.call
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
