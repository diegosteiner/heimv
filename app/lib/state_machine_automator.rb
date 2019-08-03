class StateMachineAutomator
  CircularTransitionError = Class.new(StandardError)
  Callback = Struct.new(:from, :to, :callback)

  attr_accessor :state_machine
  delegate :current_state, :transition_to, :can_transition_to?, :object, to: :state_machine

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

        passed_transitions << to if transition_to(to)
      end
    end
  end

  def next_state
    self.class.callbacks.each do |callback|
      from = callback.from
      to = callback.to
      next unless from.include?(current_state&.to_sym) || from.empty?
      next unless callback.callback.call(object) && can_transition_to?(to)

      return to
    end
    nil
  end
end
