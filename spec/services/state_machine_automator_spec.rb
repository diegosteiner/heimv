require 'rails_helper'

describe StateMachineAutomator do
  let(:object) { build_stubbed(:booking) }
  let(:state_machine_class) { Class.new(BookingStrategy::Base::StateMachine) }
  let(:state_machine) { state_machine_class.new(object) }

  describe '#automatic' do
    before do
      allow(state_machine).to receive(:current_state) do
        state_machine.object.instance_variable_get(:@current_state)
      end
      allow(state_machine).to receive(:transition_to) do |to|
        state_machine.object.instance_variable_set(:@current_state, to)
      end
    end

    test_cases = TestTupel.new(:title, :from_state, :to_state, :condition, :result) do |tupels, struct|
      tupels << struct.new('when conditions are met', :from_automatic, :to_automatic, true, %w[to_automatic])
      tupels << struct.new('when conditions are not met', :from_manual, :to_manual, false, [])
    end

    test_cases.each do |tupel|
      it tupel.title do
        state_machine_class.class_eval do
          state tupel.from_state
          state tupel.to_state
          transition from: tupel.from_state, to: tupel.to_state
          automatic_transition(from: tupel.from_state, to: tupel.to_state) { tupel.condition }
        end

        state_machine.object.instance_variable_set(:@current_state, tupel.from_state)
        expect(state_machine.automatic).to eq tupel.result
      end
    end

    context 'with circular conditions' do
      it 'throws an error' do
        state_machine_class.class_eval do
          state :one
          state :two
          transition from: :one, to: :two
          transition from: :two, to: :one
          automatic_transition(from: :one, to: :two) { true }
          automatic_transition(from: :two, to: :one) { true }
        end

        state_machine.object.instance_variable_set(:@current_state, :one)
        expect(state_machine.automatic).to eq(%w[two one])
      end
    end
  end
end
