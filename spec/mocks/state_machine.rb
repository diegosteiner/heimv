# frozen_string_literal: true

class MockStateMachine
  attr_accessor :booking_state

  def initialize(initial_state: :initial)
    @booking_state = initial_state
  end

  def transition_to(state)
    @booking_state = state
  end
end
