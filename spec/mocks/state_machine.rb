class MockStateMachine
  attr_accessor :current_state

  def initialize(initial_state: :initial)
    @current_state = initial_state
  end

  def transition_to(state)
    @current_state = state
  end
end
