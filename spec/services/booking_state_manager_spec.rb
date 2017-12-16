require 'rails_helper'

describe BookingStateManager do
  let(:booking) { build_stubbed(:booking) }
  let(:service) { described_class.new(booking) }

  describe '#state_machine' do
    subject { service.state_machine }

    it { is_expected.to be_a(BookingStateMachines::Default) }
    it { expect(service.state_machine.object).to eq(booking) }
  end

  describe 'delegates' do
    let(:delegates) do
      %i[transition_to transition_to! can_transition_to? in_state?
         current_state allowed_transitions prefered_transition]
    end
    it do
      state_machine = double
      delegates.each { |delegate| expect(state_machine).to receive(delegate) }
      allow(service).to receive(:state_machine).and_return(state_machine)
      delegates.each { |delegate| service.send(delegate) }
    end
  end
end
