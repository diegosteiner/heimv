require 'rails_helper'

describe BookingStateMachines::Base do
  let(:object) { build_stubbed(:booking) }
  let(:transition_class) { BookingTransition }
  let(:state_machine) { described_class.new(object, transition_class: transition_class) }

  describe '#initial_state' do
    let(:initial_state) { 'initial' }
    it { expect(described_class.initial_state).to eq(initial_state) }
    it { expect(state_machine.current_state).to eq(initial_state) }
  end

  describe '#prefered_transition' do
    it { expect { state_machine.prefered_transition }.to raise_error(NotImplementedError) }
  end
end
