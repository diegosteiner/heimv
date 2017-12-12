require 'rails_helper'

shared_examples 'transition' do |transition_expr, validity|
  transition_data = transition_expr.match(/(\w+)-->(\w+)/ix)
  let(:initial_state) { transition_data[1] }
  let(:target_state) { transition_data[2] }
  let(:booking) { create(:booking, initial_state: initial_state) }

  it transition_expr do
    expect(state_machine.transition_to(target_state)).to be(validity)
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
    describe 'allowed transitions' do
      it_behaves_like 'transition', 'initial-->new_request', true
      it_behaves_like 'transition', 'initial-->provisional_request', true
      it_behaves_like 'transition', 'initial-->definitive_request', true
      it_behaves_like 'transition', 'initial-->new_request', true
      it_behaves_like 'transition', 'new_request-->provisional_request', true
      it_behaves_like 'transition', 'new_request-->definitive_request', true
      it_behaves_like 'transition', 'initial-->provisional_request', true
      it_behaves_like 'transition', 'overdue_request-->definitive_request', true
      it_behaves_like 'transition', 'provisional_request-->definitive_request', true
      it_behaves_like 'transition', 'initial-->definitive_request', true
      it_behaves_like 'transition', 'overdue_request-->provisional_request', true
      it_behaves_like 'transition', 'definitive_request-->confirmed', true
      it_behaves_like 'transition', 'confirmed-->confirmed', true
      it_behaves_like 'transition', 'upcoming-->active', true
      it_behaves_like 'transition', 'active-->past', true
      it_behaves_like 'transition', 'past-->payment_due', true
      it_behaves_like 'transition', 'payment_due-->payment_due', true
      it_behaves_like 'transition', 'payment_overdue-->payment_overdue', true
    end

    describe 'automatic transitions' do
      it_behaves_like 'transition', 'provisional_request-->overdue_request', true
      # it_behaves_like 'transition', 'overdue_request-->cancelled', true
      it_behaves_like 'transition', 'confirmed-->overdue', true
      it_behaves_like 'transition', 'payment_due-->payment_overdue', true
    end

    describe 'prohibited transitions' do
      it_behaves_like 'transition', 'payment_overdue-->cancelled', false
      it_behaves_like 'transition', 'past-->confirmed', false
    end

    describe 'guarded transitions' do
      let(:bills) { double("Bills") }

      describe '-->upcoming' do
        let(:contracts) { double("Contracts") }
        before do
          allow(booking).to receive(:contracts).and_return(contracts)
          allow(booking).to receive(:bills).and_return(bills)
        end

        context 'with met preconditions' do
          before do
            allow(contracts).to receive(:any?).and_return(true)
            allow(contracts).to receive(:all?).and_return(true)
            allow(bills).to receive_message_chain(:deposits, :all?).and_return(true)
          end
          it_behaves_like 'transition', 'confirmed-->upcoming', true
          it_behaves_like 'transition', 'overdue-->upcoming', true
        end

        context 'with unmet preconditions' do
          before do
            allow(contracts).to receive(:any?).and_return(false)
            allow(contracts).to receive(:all?).and_return(false)
            allow(bills).to receive_message_chain(:deposits, :all?).and_return(false)
          end
          it_behaves_like 'transition', 'confirmed-->upcoming', false
          it_behaves_like 'transition', 'overdue-->upcoming', false
        end
      end

      describe '-->completed' do
        before do
          allow(booking).to receive(:bills).and_return(bills)
        end

        context 'with met preconditions' do
          before do
            allow(bills).to receive(:any?).and_return(true)
            allow(bills).to receive_message_chain(:open, :none?).and_return(true)
          end
          it_behaves_like 'transition', 'payment_due-->completed', true
          it_behaves_like 'transition', 'payment_overdue-->completed', true
        end

        context 'with unmet preconditions' do
          before do
            allow(bills).to receive(:any?).and_return(false)
            allow(bills).to receive_message_chain(:open, :none?).and_return(false)
          end
          it_behaves_like 'transition', 'payment_due-->completed', false
          it_behaves_like 'transition', 'payment_overdue-->completed', false
          it_behaves_like 'transition', 'past-->completed', false
        end
      end

      describe '-->cancelled' do
        before do
          allow(booking).to receive(:bills).and_return(bills)
        end

        context 'with met preconditions' do
          before do
            allow(bills).to receive_message_chain(:open, :none?).and_return(true)
          end

          it_behaves_like 'transition', 'overdue_request-->cancelled', true
          it_behaves_like 'transition', 'new_request-->cancelled', true
          it_behaves_like 'transition', 'provisional_request-->cancelled', true
          it_behaves_like 'transition', 'definitive_request-->cancelled', true
          it_behaves_like 'transition', 'confirmed-->cancelled', true
          it_behaves_like 'transition', 'overdue-->cancelled', true
          it_behaves_like 'transition', 'upcoming-->cancelled', true
        end

        context 'with unmet preconditions' do
          before do
            allow(bills).to receive_message_chain(:open, :none?).and_return(false)
          end
          it_behaves_like 'transition', 'overdue_request-->cancelled', false
          it_behaves_like 'transition', 'new_request-->cancelled', false
          it_behaves_like 'transition', 'provisional_request-->cancelled', false
          it_behaves_like 'transition', 'definitive_request-->cancelled', false
          it_behaves_like 'transition', 'confirmed-->cancelled', false
          it_behaves_like 'transition', 'overdue-->cancelled', false
          it_behaves_like 'transition', 'upcoming-->cancelled', false
        end
      end
    end
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
