# frozen_string_literal: true

class BookingStrategy
  class StateMachine
    extend TemplateRenderable
    include Statesman::Machine
    CircularTransitionError = Class.new(StandardError)

    class << self
      def state_classes
        @state_classes ||= {}
      end

      def callbacks
        @callbacks ||= {
          before: [],
          after: [],
          after_transition_failure: [],
          after_guard_failure: [],
          after_commit: [],
          infere: [],
          guards: []
        }
      end

      def mount(*state_classes, initial:)
        @states = []
        @successors = {}
        @state_classes = state_classes.index_by(&:to_sym)

        mount_states(@state_classes)
        state(initial.to_sym, initial: true)
        @state_classes[initial.to_sym] = initial
        mount_successors(@state_classes)
        mount_callbacks(@state_classes)
      end

      def mount_states(state_classes)
        state_classes.each_key { |key| state(key) }
      end

      def mount_successors(state_classes)
        state_classes.each do |key, state_class|
          transition(from: key, to: state_class.successors) if state_class.successors.present?
        end
      end

      def mount_callbacks(state_classes)
        state_classes.each_value do |state_class|
          state_class.callbacks.each do |callback_type, state_callbacks|
            state_callbacks.each do |callback|
              add_callback(callback_type: callback_type, callback_class: callback.class,
                           from: callback.from, to: callback.to, &callback.callback)
            end
          end
        end
      end
    end

    def auto(max_steps = 10)
      [].tap do |passed_transitions|
        while (to = infer_next_state) && passed_transitions.count <= max_steps
          raise CircularTransitionError if passed_transitions.include?(to)

          Statesman::Machine.retry_conflicts(3) do
            passed_transitions << to if transition_to(to)
          end
        end
      end
    end

    def infer_next_state
      self.class.callbacks[:infere].each do |callback|
        to = callback.to.first

        next unless from == current_state&.to_s || from.blank?
        next unless callback.callback.call(object) && can_transition_to?(to)

        return to
      end
      nil
    end

    def state_object
      self.class.state_classes[current_state&.to_sym]&.new(object)
    end
  end
end
