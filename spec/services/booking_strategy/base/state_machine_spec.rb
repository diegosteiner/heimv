require 'rails_helper'

describe BookingStrategy::Base::StateMachine do
  let(:object) { build_stubbed(:booking) }
  let(:state_machine) { described_class.new(object) }

  describe '#prefered_transition' do
    subject { state_machine.prefered_transition }
    let(:prefered_transitions) { { initial: :prefered } }
    let(:current_state) { prefered_transitions.keys.first }

    before do
      expect(state_machine).to receive(:current_state).and_return(current_state)
      stub_const('BookingStrategy::Base::StateMachine::PREFERED_TRANSITIONS', prefered_transitions)
    end

    it { is_expected.to eq(prefered_transitions[current_state]) }
  end
end
