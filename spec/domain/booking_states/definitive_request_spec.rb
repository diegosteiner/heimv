# frozen_string_literal: true

require 'rails_helper'

describe BookingStates::DefinitiveRequest do
  subject(:transitioned_booking) do
    booking.booking_flow.transition_to(described_class.to_sym)
    booking
  end

  let(:booking_flow_class) do
    Class.new(BookingFlows::Base) do
      state BookingStates::Initial, to: [:definitive_request], initial: true
      state BookingStates::DefinitiveRequest
    end
  end

  let(:organisation) { create(:organisation, :with_templates, booking_flow_class:) }

  let(:booking) { create(:booking, organisation:, committed_request: true) }

  let(:transition) { booking.booking_flow.transition_to(described_class.to_sym) }

  describe 'transition' do
    it { expect(transitioned_booking.booking_state).to(be_a(described_class)) }
    it { expect(transitioned_booking.deadline).to be_nil }
    it { expect(transitioned_booking).not_to be_editable }
    it { expect(transitioned_booking.committed_request).to be_truthy }
    it { expect(transitioned_booking).to be_occupied }
    it { expect(transitioned_booking).to notify(:manage_definitive_request_notification).to(:administration) }
    it { expect(transitioned_booking).to notify(:definitive_request_notification).to(:tenant) }
  end
end
