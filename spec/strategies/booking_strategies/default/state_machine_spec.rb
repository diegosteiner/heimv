require 'rails_helper'
describe BookingStrategies::Default::StateMachine do
  let(:booking) { create(:booking, skip_automatic_transition: true) }
  subject(:state_machine) { described_class.new(booking) }
  before do
    message_from_template = double('Message')
    allow(message_from_template).to receive(:deliver).and_return(true)
    allow(Message).to receive(:new_from_template).and_return(message_from_template)
  end

  describe 'allowed transitions' do
    describe 'initial-->' do
      it { is_expected.to transition.to(:unconfirmed_request) }
      it { is_expected.to transition.to(:provisional_request) }
      it { is_expected.to transition.to(:definitive_request) }
      it { is_expected.to transition.to(:unconfirmed_request) }
      it { is_expected.to transition.to(:definitive_request) }
      it { is_expected.to transition.to(:provisional_request) }

      it 'sends email-confirmation' do
        expect(Message).to receive(:new_from_template)
        is_expected.to transition.to(:unconfirmed_request)
      end
    end

    describe 'unconfirmed_request-->' do
      it { is_expected.to transition.from(:unconfirmed_request).to(:open_request) }
      it { is_expected.to transition.from(:unconfirmed_request).to(:cancelled_request) }
      it { is_expected.to transition.from(:unconfirmed_request).to(:declined_request) }
    end

    describe 'open_request-->' do
      it { is_expected.to transition.from(:open_request).to(:provisional_request) }
      it { is_expected.to transition.from(:open_request).to(:definitive_request) }
      it { is_expected.to transition.from(:open_request).to(:cancelled_request) }
      it { is_expected.to transition.from(:open_request).to(:declined_request) }
    end

    describe 'overdue_request-->' do
      it { is_expected.to transition.from(:overdue_request).to(:definitive_request) }
      it { is_expected.to transition.from(:overdue_request).to(:cancelled_request) }
      it { is_expected.to transition.from(:overdue_request).to(:declined_request) }
    end

    describe 'provisional_request-->' do
      it { is_expected.to transition.from(:provisional_request).to(:overdue_request) }
      it { is_expected.to transition.from(:provisional_request).to(:definitive_request) }
      it { is_expected.to transition.from(:provisional_request).to(:cancelled_request) }
      it { is_expected.to transition.from(:provisional_request).to(:declined_request) }
    end

    describe 'definitive_request-->' do
      it { is_expected.to transition.from(:definitive_request).to(:confirmed) }
      it { is_expected.to transition.from(:definitive_request).to(:cancelation_pending) }
    end

    describe 'upcoming-->' do
      it { is_expected.to transition.from(:upcoming).to(:cancelation_pending) }
      it { is_expected.to transition.from(:upcoming).to(:active) }
    end

    describe 'past-->' do
      it { is_expected.to transition.from(:past).to(:payment_due) }
      it { is_expected.not_to transition.from(:past).to(:confirmed) }
    end

    describe 'confirmed-->' do
      it { is_expected.to transition.from(:confirmed).to(:cancelation_pending) }
      it { is_expected.not_to transition.from(:confirmed).to(:confirmed) }
    end

    describe 'cancellation_pending-->' do
      it { is_expected.to transition.from(:cancelation_pending).to(:cancelled) }
    end
  end

  # describe "automatic transitions" do
  #   it { is_expected.to transition.from(:active).to(:past) }
  #   it { is_expected.to transition.from(:upcoming).to(:active) }
  #   it { is_expected.to transition.from(:overdue_request).to(:cancelled_request) }
  #   it { is_expected.to transition.from(:payment_due).to(:payment_overdue) }
  #   it { is_expected.to transition.from(:confirmed).to(:overdue) }
  # end

  describe 'prohibited transitions' do
    it { is_expected.not_to transition.from(:payment_due).to(:payment_due) }
    it { is_expected.not_to transition.from(:payment_overdue).to(:cancelation_pending) }
    it { is_expected.not_to transition.from(:payment_overdue).to(:payment_overdue) }
  end

  describe 'sideeffects' do
    # describe 'blocking states' do
    #   let(:states) { { confirmed: :overdue, overdue: :upcoming, upcoming: :active } }
    #   let(:occupancy) { build(:occupancy, blocking: false) }

    #   it 'sets occupancy to blocking for all blocking states' do
    #     states.each do |initial_state, state|
    #       booking = create(:booking, initial_state: initial_state, occupancy: occupancy)
    #       state_machine = described_class.new(booking)
    #       expect(state_machine.transition.from().to(state)).to be true
    #       expect(booking.occupancy.occ).to be true
    #     end
    #   end

    #   context 'unblocking states' do
    #     let(:states) { { confirmed: :cancelation_pending } }
    #     let(:occupancy) { build(:occupancy, blocking: true) }

    #     it 'sets occupancy to not blocking for all non-blocking states' do
    #       states.each do |initial_state, state|
    #         booking = create(:booking, initial_state: initial_state, occupancy: occupancy)
    #         state_machine = described_class.new(booking)
    #         expect(state_machine.transition.from().to(state)).to be true
    #         expect(booking.occupancy.blocking).to be false
    #       end
    #     end
    #   end
    # end
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

          it { is_expected.to transition.from(:confirmed).to(:upcoming) }
          it { is_expected.to transition.from(:overdue).to(:upcoming) }
        end

        context 'with unmet preconditions' do
          before do
            allow(contracts).to receive(:any?).and_return(false)
            allow(contracts).to receive(:all?).and_return(false)
            allow(bills).to receive_message_chain(:deposits, :all?).and_return(false)
          end

          it { is_expected.not_to transition.from(:confirmed).to(:upcoming) }
          it { is_expected.not_to transition.from(:overdue).to(:upcoming) }
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

          it { is_expected.to transition.from(:payment_due).to(:completed) }
          it { is_expected.to transition.from(:payment_overdue).to(:completed) }
        end

        context 'with unmet preconditions' do
          before do
            allow(bills).to receive(:any?).and_return(false)
            allow(bills).to receive_message_chain(:open, :none?).and_return(false)
          end

          it { is_expected.not_to transition.from(:payment_due).to(:completed) }
          it { is_expected.not_to transition.from(:payment_overdue).to(:completed) }
          it { is_expected.not_to transition.from(:past).to(:completed) }
        end
      end

      describe '-->cancelation_pending' do
        it { is_expected.to transition.from(:overdue_request).to(:cancelation_pending) }
        it { is_expected.to transition.from(:unconfirmed_request).to(:cancelation_pending) }
        it { is_expected.to transition.from(:provisional_request).to(:cancelation_pending) }
        it { is_expected.to transition.from(:definitive_request).to(:cancelation_pending) }
        it { is_expected.to transition.from(:confirmed).to(:cancelation_pending) }
        it { is_expected.to transition.from(:overdue).to(:cancelation_pending) }
        it { is_expected.to transition.from(:upcoming).to(:cancelation_pending) }
      end

      describe '-->cancelled' do
        before do
          allow(booking).to receive(:bills).and_return(bills)
        end

        context 'with met preconditions' do
          before do
            allow(bills).to receive_message_chain(:open, :none?).and_return(true)
          end

          it { is_expected.to transition.from(:cancelation_pending).to(:cancelled) }
        end

        context 'with unmet preconditions' do
          before do
            allow(bills).to receive_message_chain(:open, :none?).and_return(false)
          end

          it { is_expected.not_to transition.from(:cancelation_pending).to(:cancelled) }
        end
      end
    end
  end
end
