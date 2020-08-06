# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :transition do |_expected|
  match do
    allow(actual).to receive(:current_state).and_wrap_original do |original, *args|
      @current_state.presence || original.call(*args)
    end
    actual.transition_to(@to_state)
  end

  chain :to do |to_state|
    @to_state = to_state
  end

  chain :from do |from_state|
    @current_state = @from_state = from_state
  end
end
