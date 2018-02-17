module BookingStrategy
  module Base
    module Automator
      module ClassMethods
        def automatic_transition(options = {}, &block)
          callbacks[:automatic] ||= []
          add_callback(callback_type: :automatic, callback_class: Statesman::Callback,
                       from: options[:from], to: options[:to], &block)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
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
    end
  end
end
