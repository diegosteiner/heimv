require 'rails_helper'

describe BookingStrategy::Base::StateMachine do
  let(:object) { build_stubbed(:booking) }
  let(:transition_class) { BookingTransition }
  let(:state_machine) { described_class.new(object, transition_class: transition_class) }

  describe '#prefered_transition' do
    subject { state_machine.prefered_transition }
    let(:prefered_transitions) { { initial: :prefered } }
    let(:current_state) { prefered_transitions.keys.first }

    before do
      expect(state_machine).to receive(:current_state).and_return(current_state)
      stub_const('BookingStrategy::Base::StateMachine::PREFERED_TRANSITIONS', prefered_transitions)
    end

    context 'without hint' do
      it { is_expected.to eq(prefered_transitions[current_state]) }
    end
  end

  describe '::automatic_transition' do
    it do
      expect(described_class).to receive(:add_callback).and_return(true)
      expect(described_class.automatic_transition).to be true
    end
  end

  describe '#automatic' do
    context 'with conditions being fulfilled' do
      it 'adds a callback' do
        from_state = :from_automatic
        to_state = :to_automatic
        described_class.class_eval do
          state from_state
          state to_state
          transition from: from_state, to: to_state
          automatic_transition(from: from_state, to: to_state) { true }
        end
        allow(state_machine).to receive(:current_state).and_return(from_state)
        expect(state_machine).to receive(:transition_to).with([to_state.to_s]).and_return(true)
        expect(state_machine.automatic).to be true
      end
    end

    context 'with conditions not being fulfilled' do
      it 'adds a callback' do
        from_state = :from_manual
        to_state = :to_manual
        described_class.class_eval do
          state from_state
          state to_state
          transition from: from_state, to: to_state
          automatic_transition(from: from_state, to: to_state) { false }
        end
        allow(state_machine).to receive(:current_state).and_return(from_state)
        expect(state_machine).not_to receive(:transition_to)
        expect(state_machine.automatic).to be false
      end
    end
  end
end
