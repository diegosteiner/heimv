require 'rails_helper'

describe StateMachineAutomator do
  let(:object) { build_stubbed(:booking) }
  let(:booking_strategy) { BookingStrategy.new }
  let(:state_machine) { booking_strategy.state_machine.new(object) }
  let(:state_machine_automator_class) { Class.new(described_class) }
  let(:state_machine_automator) { state_machine_automator_class.new(state_machine) }

  before do
    object.state = :matching
    allow(Booking).to receive(:strategy).and_return(booking_strategy)
    allow(object).to receive(:state_machine).and_return(state_machine)
    allow(state_machine).to receive(:current_state) { object.state }
    allow(state_machine).to receive(:can_transition_to?).and_return(true)
    allow(state_machine).to receive(:transition_to) do |to|
      state_machine.object.state = to
      true
    end
  end

  describe '#next_state' do
    subject { state_machine_automator.next_state }

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

    context 'with no circular conditions' do
      before { state_machine_automator_class.automatic_transition(from: :matching, to: :next) { |_| true } }

      it { is_expected.to eq([:next]) }
    end

    context 'with circular conditions' do
      before do
        state_machine_automator_class.automatic_transition(from: :one, to: :two) { |_| true }
        state_machine_automator_class.automatic_transition(from: :two, to: :one) { |_| true }
      end

      it 'throws an error' do
        state_machine.class_eval do
          state :one
          state :two
          transition from: :one, to: :two
          transition from: :two, to: :one
        end

        state_machine.object.state = :one
        expect { subject }.to raise_error StateMachineAutomator::CircularTransitionError
      end
    end
  end
end
