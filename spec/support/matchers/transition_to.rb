# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :transition_to do |to_state|
  match do |state_machine|
    allow(state_machine).to receive(:current_state).and_wrap_original do |original, *args|
      @from_state.presence || original.call(*args)
    end
    state_machine.transition_to(to_state)
  end

  chain :from do |from_state|
    @from_state = from_state
  end
end
