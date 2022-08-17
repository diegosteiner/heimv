# frozen_string_literal: true

require 'rails_helper'

describe BookingActions::Public::PostponeDeadline do
  let(:booking) { create(:booking, initial_state: initial_state) }
  let(:deadline) { create(:deadline, booking: booking, at: 2.days.from_now, postponable_for: 1.day) }
  let(:initial_state) { :provisional_request }
  let(:booking_flow) { double }
  subject(:action) { described_class.call(booking: booking) }

  before do
    allow(booking).to receive(:deadline).and_return(deadline)
    allow(booking).to receive(:booking_flow).and_return(booking_flow)
    allow(booking_flow).to receive(:booking_state).and_return(initial_state)
    allow(booking_flow).to receive(:infer).and_return([])
  end

  context 'when deadline is not postponable' do
    let!(:deadline) { create(:deadline, booking: booking, postponable_for: nil) }

    it { expect { action }.to raise_error(BookingActions::Base::NotAllowed) }
  end

  context 'with provisional_request' do
    it { expect { action }.to(change { booking.deadline.at }) }

    context 'when booking is too close' do
      let(:occupancy) { build(:occupancy, begins_at: 3.days.from_now, ends_at: 4.days.from_now) }
      let(:booking) { create(:booking, initial_state: initial_state, occupancy: occupancy) }

      it { expect { action }.to raise_error(BookingActions::Base::NotAllowed) }
    end
  end

  context 'with overdue_request' do
    let(:initial_state) { :overdue_request }

    it do
      expect(booking.deadline).to receive(:postpone)
      action
    end
  end

  context 'with payment_overdue' do
    let(:initial_state) { :payment_overdue }

    it do
      expect(booking.deadline).to receive(:postpone)
      action
    end
  end
end
