module BookingStateMachines
  class Base
    PREFERED_TRANSITIONS = {}.freeze
    PUBLIC_TRANSITIONS = [].freeze

    include Statesman::Machine

    state :initial, initial: true

    def prefered_transition(hint = nil)
      self.class::PREFERED_TRANSITIONS.with_indifferent_access.dig(*[current_state, hint].compact)
    end

    def allowed_public_transitions
      allowed_transitions & self.class::PUBLIC_TRANSITIONS
    end

    def automatic
      ts = select_callbacks_for(self.class.callbacks[:automatic], from: current_state)
      ts.any? do |t|
        transition_to(t.to) if t.call
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
