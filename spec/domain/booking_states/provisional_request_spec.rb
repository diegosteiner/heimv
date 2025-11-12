# frozen_string_literal: true

require 'rails_helper'

describe BookingStates::ProvisionalRequest do
  subject(:transitioned_booking) do
    booking.booking_flow.transition_to(described_class.to_sym)
    booking
  end

  let(:booking_flow_class) do
    Class.new(BookingFlows::Base) do
      state BookingStates::Initial, to: [:provisional_request], initial: true
      state BookingStates::ProvisionalRequest
    end
  end

  let(:organisation) { create(:organisation, :with_templates, booking_flow_class:) }

  let(:booking) { create(:booking, organisation:, committed_request: false) }

  let(:transition) { booking.booking_flow.transition_to(described_class.to_sym) }

  describe 'transition' do
    it { expect(transitioned_booking.booking_state).to(be_a(described_class)) }
    it { expect(transitioned_booking.deadline).not_to be_nil }
    it { expect(transitioned_booking).to be_tentative }
    it { expect(transitioned_booking).to be_editable }
    it { expect(transitioned_booking.committed_request).to be_falsy }
    it { expect(transitioned_booking).to notify(:provisional_request_notification).to(:tenant) }
  end
end
