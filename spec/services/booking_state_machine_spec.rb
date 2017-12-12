require 'rails_helper'

shared_examples 'transition' do |transition_expr, validity|
  transition_data = transition_expr.match(/(\w+)-->(\w+)/ix)
  let(:initial_state) { transition_data[1] }
  let(:target_state) { transition_data[2] }
  let(:booking) { create(:booking, initial_state: initial_state) }

  it transition_expr do
    expect(state_machine.transition_to!(target_state)).to be(validity)
    expect(state_machine.current_state).to eq((validity ? target_state : initial_state))
  end
end

describe BookingStateMachine do
  let(:booking) { build_stubbed(:booking) }
  let(:state_machine) { described_class.new(booking, transition_class: BookingTransition) }

  describe 'states' do
    let(:booking) { create(:booking) }

    it do
      expect(booking).to be_valid
      expect(booking.save).to be true
    end
  end

  describe 'transitions' do
    it_behaves_like 'transition', 'initial-->new_request', true
    it_behaves_like 'transition', 'initial-->provisional_request', true
    it_behaves_like 'transition', 'initial-->definitive_request', true
    it_behaves_like 'transition', 'new_request-->provisional_request', true
    it_behaves_like 'transition', 'new_request-->definitive_request', true
    it_behaves_like 'transition', 'new_request-->cancelled', true
  end

  describe '::state_enum' do
    let(:states) do
      %i[initial new_request provisional_request definitive_request overdue_request cancelled
         confirmed upcoming overdue active past payment_due payment_overdue completed]
    end
    let(:states_hash) { Hash[states.map { |state| [state, state.to_s] }] }
    subject { described_class.states_enum_hash }
    it { is_expected.to eq(states_hash) }
  end
end
