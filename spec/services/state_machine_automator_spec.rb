require 'rails_helper'

describe StateMachineAutomator do
  let(:object) { build_stubbed(:booking) }
  let(:state_machine) { BookingStrategy::Base::StateMachine.new(object) }
  let(:state_machine_automator_class) { Class.new(described_class) }
  let(:state_machine_automator) { state_machine_automator_class.new(state_machine) }

  describe '#run' do
  end

  describe '#next_state' do
    subject { state_machine_automator.next_state }
    before do
      allow(state_machine).to receive(:current_state).and_return(:matching)
      allow(state_machine).to receive(:can_transition_to?).and_return(true)
    end

    context 'with matching state' do
      context 'and matching condition' do
        before { state_machine_automator_class.automatic_transition(from: :matching, to: :next) { |_| true } }
        it { is_expected.to be(:next) }
      end

      context 'and not matching condition' do
        before { state_machine_automator_class.automatic_transition(from: :matching, to: :next) { |_| false } }
        it { is_expected.to be(nil) }
      end
    end

    context 'without matching state' do
      before { state_machine_automator_class.automatic_transition(from: :not_matching, to: :next) { |_| false } }
      it { is_expected.to be(nil) }
    end
  end

  describe '#run' do
    subject { state_machine_automator.run }
    before do
      allow(state_machine).to receive(:current_state).and_return(:matching)
      allow(state_machine).to receive(:can_transition_to?).and_return(true)
      expect(state_machine).to receive(:transition_to).and_return(true)
    end

    context 'with no circular conditions' do
      before { state_machine_automator_class.automatic_transition(from: :matching, to: :next) { |_| true } }
      it { is_expected.to eq([:next]) }
    end

    context 'with circular conditions' do
      # it 'throws an error' do
      #   state_machine_class.class_eval do
      #     state :one
      #     state :two
      #     transition from: :one, to: :two
      #     transition from: :two, to: :one
      #     automatic_transition(from: :one, to: :two) { true }
      #     automatic_transition(from: :two, to: :one) { true }
      #   end

      #   state_machine.object.instance_variable_set(:@current_state, :one)
      #   expect(state_machine.automatic).to eq(%w[two one])
      # end
    end
  end
end
