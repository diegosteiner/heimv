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
        [].tap do |passed_transitions|
          while (to = automatic_step_to)
            raise StandardError if passed_transitions.include?(to)
            transition_to(to)
            passed_transitions << to
          end
        end
      end

      def automatic_step_to
        condition = select_callbacks_for(self.class.callbacks[:automatic], from: current_state).find(&:call)
        return nil unless condition
        condition.to.first
      end

      # def automatic(passed_transitions = [])
      #   conditions = select_callbacks_for(self.class.callbacks[:automatic], from: current_state)
      #   to = automatic_step_to
      #   return passed_transitions unless to
      #   raise StandardError if passed_transitions.include?(to)
      #   transition_to(to)
      #   automatic(passed_transitions + [to])
      # end

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
