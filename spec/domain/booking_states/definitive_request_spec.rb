# frozen_string_literal: true

require 'rails_helper'

describe BookingStates::DefinitiveRequest do
  booking_flow_class = Class.new(BookingFlows::Base) do
    state BookingStates::Initial, to: [:definitive_request], initial: true
    state BookingStates::DefinitiveRequest
  end
  let(:organisation) { create(:organisation, :with_templates, booking_flow_class:) }
  subject(:booking) { create(:booking, organisation:, committed_request: true) }
  subject(:transition) { booking.booking_flow.transition_to(described_class.to_sym) }
  subject(:transitioned_booking) do
    booking.booking_flow.transition_to(described_class.to_sym)
    booking
  end

  describe 'transition' do
    it { expect(transitioned_booking.booking_state).to(be_a(described_class)) }
    it { expect(transitioned_booking.deadline).to be(nil) }
    it { expect(transitioned_booking.editable?).to be_falsy }
    it { expect(transitioned_booking.committed_request).to be_truthy }
    it { expect(transitioned_booking).to be_occupied }
    it { expect(transitioned_booking).to notify(:manage_definitive_request_notification).to(:administration) }
    it { expect(transitioned_booking).to notify(:definitive_request_notification).to(:tenant) }
  end
end
