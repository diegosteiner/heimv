require 'rails_helper'
describe BookingStrategies::Default::StateMachine do
  def state_machine_in_state(initial_state, options = {})
    booking = create(:booking, options.merge(initial_state: initial_state))
    described_class.new(booking)
  end

  describe 'allowed transitions' do
    describe 'initial-->' do
      subject { state_machine_in_state(:initial, skip_automatic_transition: true) }

      it { is_expected.to transition_to(:unconfirmed_request) }
      it { is_expected.to transition_to(:provisional_request) }
      it { is_expected.to transition_to(:definitive_request) }
      it { is_expected.to transition_to(:unconfirmed_request) }
      it { is_expected.to transition_to(:definitive_request) }
      it { is_expected.to transition_to(:provisional_request) }

      it 'sends email-confirmation' do
        expect(Message).to receive_message_chain(:new_from_template)
        is_expected.to transition_to(:unconfirmed_request)
      end
    end

    describe 'unconfirmed_request-->' do
      subject { state_machine_in_state(:unconfirmed_request) }
      before { allow(BookingMailer).to receive_message_chain(:new_booking, :deliver_now) }

      it { is_expected.to transition_to(:open_request) }
      it { is_expected.to transition_to(:cancelation_pending) }
    end

    describe 'open_request-->' do
      subject { state_machine_in_state(:open_request) }

      it { is_expected.to transition_to(:provisional_request) }
      it { is_expected.to transition_to(:definitive_request) }
    end

    describe 'overdue_request-->' do
      subject { state_machine_in_state(:overdue_request) }

      it { is_expected.to transition_to(:definitive_request) }
      it { is_expected.to transition_to(:cancelation_pending) }
      it { is_expected.to transition_to(:provisional_request) }
    end

    describe 'provisional_request-->' do
      subject { state_machine_in_state(:provisional_request) }

      it { is_expected.to transition_to(:overdue_request) }
      it { is_expected.to transition_to(:definitive_request) }
      it { is_expected.to transition_to(:cancelation_pending) }
    end

    describe 'definitive_request-->' do
      subject { state_machine_in_state(:definitive_request) }

      it { is_expected.to transition_to(:confirmed) }
      it { is_expected.to transition_to(:cancelation_pending) }
    end

    describe 'upcoming-->' do
      subject { state_machine_in_state(:upcoming) }

      it { is_expected.to transition_to(:cancelation_pending) }
    end

    describe 'past-->' do
      subject { state_machine_in_state(:past) }
      it { is_expected.to transition_to(:payment_due) }
      it { is_expected.not_to transition_to(:confirmed) }
    end

    describe 'confirmed-->' do
      subject { state_machine_in_state(:confirmed) }

      it { is_expected.to transition_to(:cancelation_pending) }
      it { is_expected.not_to transition_to(:confirmed) }
    end
  end

  describe 'automatic transitions' do
    it { expect(state_machine_in_state(:active)).to transition_to(:past) }
    it { expect(state_machine_in_state(:upcoming)).to transition_to(:active) }
    it { expect(state_machine_in_state(:overdue_request)).to transition_to(:cancelation_pending) }
    it { expect(state_machine_in_state(:payment_due)).to transition_to(:payment_overdue) }
    it { expect(state_machine_in_state(:confirmed)).to transition_to(:overdue) }
  end

  describe 'prohibited transitions' do
    it { expect(state_machine_in_state(:payment_due)).not_to transition_to(:payment_due) }
    it { expect(state_machine_in_state(:payment_overdue)).not_to transition_to(:cancelation_pending) }
    it { expect(state_machine_in_state(:payment_overdue)).not_to transition_to(:payment_overdue) }
  end

  describe 'sideeffects' do
    # describe 'blocking states' do
    #   let(:states) { { confirmed: :overdue, overdue: :upcoming, upcoming: :active } }
    #   let(:occupancy) { build(:occupancy, blocking: false) }

    #   it 'sets occupancy to blocking for all blocking states' do
    #     states.each do |initial_state, state|
    #       booking = create(:booking, initial_state: initial_state, occupancy: occupancy)
    #       state_machine = described_class.new(booking)
    #       expect(state_machine.transition_to(state)).to be true
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
    #         expect(state_machine.transition_to(state)).to be true
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
          it do
            it { expect(state_machine_in_state(:confirmed)).to transition_to(:upcoming) }
            it { expect(state_machine_in_state(:overdue)).to transition_to(:upcoming) }
          end
        end

        context 'with unmet preconditions' do
          before do
            allow(contracts).to receive(:any?).and_return(false)
            allow(contracts).to receive(:all?).and_return(false)
            allow(bills).to receive_message_chain(:deposits, :all?).and_return(false)
          end
          it do
            it { expect(state_machine_in_state(:confirmed)).not_to transition_to(:upcoming) }
            it { expect(state_machine_in_state(:overdue)).not_to transition_to(:upcoming) }
          end
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
          it do
            it { expect(state_machine_in_state(:payment_due)).to transition_to(:completed) }
            it { expect(state_machine_in_state(:payment_overdue)).to transition_to(:completed) }
          end
        end

        context 'with unmet preconditions' do
          before do
            allow(bills).to receive(:any?).and_return(false)
            allow(bills).to receive_message_chain(:open, :none?).and_return(false)
          end
          it do
            it { expect(state_machine_in_state(:payment_due)).not_to transition_to(:completed) }
            it { expect(state_machine_in_state(:payment_overdue)).not_to transition_to(:completed) }
            it { expect(state_machine_in_state(:past)).not_to transition_to(:completed) }
          end
        end
      end

      describe '-->cancelation_pending' do
        before do
          allow(booking).to receive(:bills).and_return(bills)
        end

        context 'with met preconditions' do
          before do
            allow(bills).to receive_message_chain(:open, :none?).and_return(true)
          end

          it do
            it { expect(state_machine_in_state(:overdue_request)).to transition_to(:cancelation_pending) }
            it { expect(state_machine_in_state(:unconfirmed_request)).to transition_to(:cancelation_pending) }
            it { expect(state_machine_in_state(:provisional_request)).to transition_to(:cancelation_pending) }
            it { expect(state_machine_in_state(:definitive_request)).to transition_to(:cancelation_pending) }
            it { expect(state_machine_in_state(:confirmed)).to transition_to(:cancelation_pending) }
            it { expect(state_machine_in_state(:overdue)).to transition_to(:cancelation_pending) }
            it { expect(state_machine_in_state(:upcoming)).to transition_to(:cancelation_pending) }
          end
        end

        context 'with unmet preconditions' do
          before do
            allow(bills).to receive_message_chain(:open, :none?).and_return(false)
          end
          it do
            it { expect(state_machine_in_state(:overdue_request)).not_to transition_to(:cancelation_pending) }
            it { expect(state_machine_in_state(:unconfirmed_request)).not_to transition_to(:cancelation_pending) }
            it { expect(state_machine_in_state(:provisional_request)).not_to transition_to(:cancelation_pending) }
            it { expect(state_machine_in_state(:definitive_request)).not_to transition_to(:cancelation_pending) }
            it { expect(state_machine_in_state(:confirmed)).not_to transition_to(:cancelation_pending) }
            it { expect(state_machine_in_state(:overdue)).not_to transition_to(:cancelation_pending) }
            it { expect(state_machine_in_state(:upcoming)).not_to transition_to(:cancelation_pending) }
          end
        end
      end
    end
  end
end
