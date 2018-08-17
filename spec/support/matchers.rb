require 'rspec/expectations'

RSpec::Matchers.define :transition_to do |expected|
  match do |actual|
    # initial_state = actual.current_state
    result = actual.transition_to(expected) && actual.current_state.to_s == expected.to_s
    # binding.pry unless result
    result
  end

  match_when_negated do |actual|
    initial_state = actual.current_state
    !actual.transition_to(expected) && actual.current_state.to_s == initial_state.to_s
  end

  # chain :from do |initial_state|
  #   actual = actual.new(FactoryBot.create(:booking, initial_state: initial_state))
  # end
end
