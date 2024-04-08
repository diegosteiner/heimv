# frozen_string_literal: true

require 'rails_helper'

describe BookingActions::Public::PostponeDeadline do
  subject(:action) { described_class.new(booking) }
  subject(:invoke) { action.invoke }

  let(:booking) { create(:booking, initial_state:) }
  let(:deadline) { create(:deadline, booking:, at: 2.days.from_now, postponable_for: 1.day) }
  let(:initial_state) { :provisional_request }
  let(:booking_flow) { double }

  before do
    allow(booking).to receive(:deadline).and_return(deadline)
    allow(booking).to receive(:booking_flow).and_return(booking_flow)
    allow(booking_flow).to receive(:booking_state).and_return(initial_state)
    allow(booking_flow).to receive(:infer).and_return([])
  end

  context 'when deadline is not postponable' do
    let!(:deadline) { create(:deadline, booking:, postponable_for: nil) }

    it { expect(invoke.success).to be_falsy }
  end

  context 'with provisional_request' do
    it { expect { invoke }.to(change { booking.deadline.at }) }

    context 'when booking is too close' do
      let(:booking) do
        create(:booking, initial_state:, begins_at: 2.days.from_now, ends_at: 4.days.from_now)
      end

      it { expect(invoke.success).to be_falsy }
    end
  end

  context 'with overdue_request' do
    let(:initial_state) { :overdue_request }

    it do
      expect(booking.deadline).to receive(:postpone)
      invoke
    end
  end

  context 'with payment_overdue' do
    let(:initial_state) { :payment_overdue }

    it do
      expect(booking.deadline).to receive(:postpone)
      invoke
    end
  end
end
