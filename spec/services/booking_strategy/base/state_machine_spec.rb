require 'rails_helper'

describe BookingStrategy::Base::StateMachine do
  let(:object) { build_stubbed(:booking) }
  let(:transition_class) { BookingTransition }
  let(:state_machine) { described_class.new(object, transition_class: transition_class) }

  # describe '#prefered_transition' do
  #   subject { state_machine.prefered_transition }
  #   let(:prefered_transitions) { { initial: :prefered } }
  #   let(:current_state) { prefered_transitions.keys.first }

  #   before do
  #     expect(state_machine).to receive(:current_state).and_return(current_state)
  #     stub_const('BookingStrategy::Base::StateMachine::PREFERED_TRANSITIONS', prefered_transitions)
  #   end

  #   context 'without hint' do
  #     it { is_expected.to eq(prefered_transitions[current_state]) }
  #   end
  # end

  describe '::automatic_transition' do
    it do
      expect(described_class).to receive(:add_callback).and_return(true)
      expect(described_class.automatic_transition).to be true
    end
  end

  describe '#automatic' do
    let(:state_machine_class) do
      Class.new(described_class)
    end
    let(:state_machine) { state_machine_class.new(object, transition_class: transition_class) }
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
        expect { state_machine.automatic }.to raise_error(StandardError)
      end
    end
  end
end
