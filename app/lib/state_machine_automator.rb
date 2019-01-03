class StateMachineAutomator
  class CircularTransitionError < StandardError; end
  Callback = Struct.new(:from, :to, :callback)

  attr_accessor :state_machine
  delegate :current_state, :transition_to, :object, to: :state_machine

  def initialize(state_machine)
    @state_machine = state_machine
  end

  class << self
    def automatic_transition(from: [], to:, &block)
      callbacks << Callback.new(Array.wrap(from).map(&:to_sym), to, block)
    end

    def callbacks
      @callbacks ||= []
    end
  end

  def run(max_steps = 10)
    [].tap do |passed_transitions|
      while (to = next_state) && passed_transitions.count <= max_steps
        raise CircularTransitionError if passed_transitions.include?(to)

        # break if passed_transitions.include?(to)

        passed_transitions << to if @state_machine.transition_to(to)
      end
    end
  end

  def next_state
    current_state = @state_machine.current_state&.to_sym
    self.class.callbacks.each do |callback|
      next unless callback.from.include?(current_state) || callback.from.empty?

      to = callback.to
      return to if callback.callback.call(@state_machine.object) && @state_machine.can_transition_to?(to)
    end
    nil
  end
end
