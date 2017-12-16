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

describe BookingStateMachines::Default do
  let(:state_machine) { described_class.new(booking, transition_class: BookingTransition) }

  describe 'allowed transitions' do
    it_behaves_like 'transition', 'initial-->new_request', true
    it_behaves_like 'transition', 'initial-->provisional_request', true
    it_behaves_like 'transition', 'initial-->definitive_request', true
    it_behaves_like 'transition', 'initial-->new_request', true
    it_behaves_like 'transition', 'new_request-->provisional_request', true
    it_behaves_like 'transition', 'new_request-->definitive_request', true
    it_behaves_like 'transition', 'new_request-->cancelled', true
    it_behaves_like 'transition', 'initial-->provisional_request', true
    it_behaves_like 'transition', 'overdue_request-->definitive_request', true
    it_behaves_like 'transition', 'overdue_request-->cancelled', true
    it_behaves_like 'transition', 'provisional_request-->overdue_request', true
    it_behaves_like 'transition', 'provisional_request-->definitive_request', true
    it_behaves_like 'transition', 'provisional_request-->cancelled', true
    it_behaves_like 'transition', 'initial-->definitive_request', true
    it_behaves_like 'transition', 'overdue_request-->provisional_request', true
    it_behaves_like 'transition', 'definitive_request-->confirmed', true
    it_behaves_like 'transition', 'definitive_request-->cancelled', true
    it_behaves_like 'transition', 'upcoming-->cancelled', true
    it_behaves_like 'transition', 'past-->payment_due', true
    it_behaves_like 'transition', 'confirmed-->cancelled', true
  end

  describe 'automatic transitions' do
    it_behaves_like 'transition', 'active-->past', true
    it_behaves_like 'transition', 'upcoming-->active', true
    it_behaves_like 'transition', 'overdue_request-->cancelled', true
    it_behaves_like 'transition', 'confirmed-->overdue', true
    it_behaves_like 'transition', 'payment_due-->payment_overdue', true
  end

  describe 'prefered transitions' do
    subject { state_machine.prefered_transition }

    let(:initial_state) { :provisional_request }
    let(:booking) { create(:booking, initial_state: initial_state) }

    it { is_expected.to eq(:definitive_request) }
  end

  describe 'prohibited transitions' do
    it_behaves_like 'transition', 'payment_due-->payment_due', false
    it_behaves_like 'transition', 'payment_overdue-->cancelled', false
    it_behaves_like 'transition', 'payment_overdue-->payment_overdue', false
    it_behaves_like 'transition', 'confirmed-->confirmed', false
    it_behaves_like 'transition', 'past-->confirmed', false
  end

  describe 'sideeffects' do
    describe 'booking.occupancy.blocking' do
      context 'blocking states' do
        let(:states) { { confirmed: :overdue, overdue: :upcoming, upcoming: :active } }
        let(:occupancy) { build(:occupancy, blocking: false) }

        it 'sets occupancy to blocking for all blocking states' do
          states.each do |initial_state, state|
            booking = create(:booking, initial_state: initial_state, occupancy: occupancy)
            state_machine = described_class.new(booking, transition_class: BookingTransition)
            expect(state_machine.transition_to(state)).to be true
            expect(booking.occupancy.blocking).to be true
          end
        end
      end

      context 'unblocking states' do
        let(:states) { { confirmed: :cancelled } }
        let(:occupancy) { build(:occupancy, blocking: true) }

        it 'sets occupancy to not blocking for all non-blocking states' do
          states.each do |initial_state, state|
            booking = create(:booking, initial_state: initial_state, occupancy: occupancy)
            state_machine = described_class.new(booking, transition_class: BookingTransition)
            expect(state_machine.transition_to(state)).to be true
            expect(booking.occupancy.blocking).to be false
          end
        end
      end
    end
  end

  describe 'guarded transitions' do
    skip 'Bills & Contracts needed' do
      let(:bills) { double('Bills') }

      describe '-->upcoming' do
        let(:contracts) { double('Contracts') }
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
end
