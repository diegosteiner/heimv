module BookingStrategy
  module Base
    module Automator
      module ClassMethods
        def automatic_transition(options = {}, &block)
          from = array_to_s_or_nil(options.fetch(:from, states))
          to = to_s_or_nil(options[:to])

          callbacks[:automatic] ||= []
          callbacks[:automatic] << Statesman::Callback.new(from: from, to: to, callback: block)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      def automatic
        [].tap do |passed_transitions|
          while (to = automatic_step_to)
            # raise StandardError if passed_transitions.include?(to)
            break if passed_transitions.include?(to)
            passed_transitions << to if transition_to(to)
          end
        end
      end

      def automatic_step_to
        self.class.callbacks[:automatic].each do |callback|
          next unless Array.wrap(callback.from).include?(current_state.to_s)
          to = callback.to.first
          return to if callback.call(@object) && can_transition_to?(to)
        end
        nil
      end
    end
  end
end
