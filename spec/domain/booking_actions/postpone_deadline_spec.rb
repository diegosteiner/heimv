# frozen_string_literal: true

require 'rails_helper'

describe BookingActions::PostponeDeadline do
  subject(:invoke) { action.invoke }

  let(:action) { described_class.new(booking, :postpone_deadline) }
  let(:booking) { create(:booking, initial_state:) }
  let(:deadline) { create(:deadline, booking:, at: 2.days.from_now, postponable_for: 1.day) }
  let(:initial_state) { :provisional_request }
  let(:booking_flow) { double }

  before do
    allow(booking).to receive_messages(deadline: deadline, booking_flow: booking_flow)
    allow(booking_flow).to receive_messages(booking_state: initial_state, current_state: initial_state, infer: [])
    allow(deadline).to receive(:postpone).and_call_original
  end

  context 'when deadline is not postponable' do
    let!(:deadline) { create(:deadline, booking:, postponable_for: nil) }

    it { is_expected.to have_attributes(error: BookingActions::Base.translate(:not_allowed)) }
  end

  context 'with provisional_request' do
    it { expect { invoke }.to(change { booking.deadline.at }) }

    context 'when booking is too close' do
      let(:booking) { create(:booking, initial_state:, begins_at: 2.days.from_now, ends_at: 4.days.from_now) }

      it { is_expected.to have_attributes(error: BookingActions::Base.translate(:not_allowed)) }
    end
  end

  context 'with overdue_request' do
    let(:initial_state) { :overdue_request }

    it do
      invoke
      expect(booking.deadline).to have_received(:postpone)
    end
  end

  context 'with payment_overdue' do
    let(:initial_state) { :payment_overdue }

    it do
      invoke
      expect(booking.deadline).to have_received(:postpone)
    end
  end
end
