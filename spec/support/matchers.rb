require 'rspec/expectations'

RSpec::Matchers.define :transition_to do |expected|
  match do |actual|
    # initial_state = actual.current_state
    actual.transition_to(expected) && actual.current_state.to_s == expected.to_s
  end

  match_when_negated do |actual|
    initial_state = actual.current_state
    !actual.transition_to(expected) && actual.current_state.to_s == initial_state.to_s
  end
end
