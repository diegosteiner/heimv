require 'rails_helper'

describe BookingStrategies::Default::Actions::Public::ExtendDeadline do
  let(:booking) { create(:booking, initial_state: initial_state) }
  let(:deadline) { create(:deadline, booking: booking, at: 2.days.from_now, extendable: 1) }
  let(:initial_state) { :provisional_request }
  let(:state_machine) { double }
  subject(:action) { described_class.call(booking: booking) }

  before do
    allow(booking).to receive(:deadline).and_return(deadline)
    allow(booking).to receive(:state_machine).and_return(state_machine)
    allow(state_machine).to receive(:current_state).and_return(initial_state)
  end

  context 'when deadline is not extendable' do
    let!(:deadline) { create(:deadline, booking: booking, extendable: 0) }

    it { expect { action }.to raise_error(BookingStrategy::Action::NotAllowed) }
  end

  context 'with provisional_request' do
    it { expect { action }.to(change { booking.deadline.at }) }

    context 'when booking is too close' do
      let(:occupancy) { build(:occupancy, begins_at: 3.days.from_now, ends_at: 4.days.from_now) }
      let(:booking) { create(:booking, initial_state: initial_state, occupancy: occupancy) }

      it do
        expect(booking.organisation).to receive(:long_deadline).at_least(:once).and_return(8.days)
        expect(booking.deadline).not_to receive(:extend_until)
        action
        expect(booking.errors).to have_key(:deadline)
      end
    end
  end

  context 'with overdue_request' do
    let(:initial_state) { :overdue_request }

    it do
      expect(state_machine).to receive(:transition_to).with(:provisional_request)
      expect(booking.deadline).to receive(:extend_until)
      action
    end
  end

  context 'with payment_overdue' do
    let(:initial_state) { :payment_overdue }

    it do
      expect(state_machine).to receive(:transition_to).with(:payment_due)
      expect(booking.deadline).to receive(:extend_until)
      action
    end
  end
end
