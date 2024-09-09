# frozen_string_literal: true

require 'rails_helper'

describe BookingStates::Upcoming do
  booking_flow_class = Class.new(BookingFlows::Base) do
    state BookingStates::Initial, to: [:upcoming], initial: true
    state BookingStates::Upcoming
  end
  let(:organisation) { create(:organisation, :with_templates, booking_flow_class:) }
  subject(:booking) { create(:booking, organisation:, committed_request: false) }
  subject(:transition) { booking.booking_flow.transition_to(described_class.to_sym) }
  subject(:transitioned_booking) do
    booking.booking_flow.transition_to(described_class.to_sym)
    booking.save
    booking
  end

  describe 'transition' do
    it { expect(transitioned_booking.booking_state).to(be_a(described_class)) }
    it { expect(transitioned_booking.deadline).to be(nil) }
    it { expect(transitioned_booking).to be_occupied }
    it { expect(transitioned_booking).to notify(:upcoming_notification).to(:tenant) }
    it { expect(transitioned_booking.notifications.count).to eq(1) }

    context 'with operator' do
      let(:operator) { create(:operator, organisation:) }
      let!(:home_handover) { create(:operator_responsibility, booking:, operator:, responsibility: :home_handover) }

      it { expect(transitioned_booking).to notify(:operator_upcoming_notification) }
    end
  end
end
