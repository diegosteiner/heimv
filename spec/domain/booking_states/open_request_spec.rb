# frozen_string_literal: true

require 'rails_helper'

describe BookingStates::OpenRequest do
  booking_flow_class = Class.new(BookingFlows::Base) do
    state BookingStates::Initial, to: [:open_request], initial: true
    state BookingStates::OpenRequest
  end
  subject(:transitioned_booking) do
    booking.booking_flow.transition_to(described_class.to_sym)
    booking
  end

  let(:organisation) { create(:organisation, :with_templates, booking_flow_class:) }

  let(:booking) { create(:booking, organisation:) }

  let(:transition) { booking.booking_flow.transition_to(described_class.to_sym) }

  describe 'transition' do
    it { expect(transitioned_booking.booking_state).to(be_a(described_class)) }
    it { expect(transitioned_booking.deadline).to be_nil }
    it { expect(transitioned_booking).to notify(:manage_new_booking_notification).to(:administration) }
    it { expect(transitioned_booking).to notify(:open_request_notification).to(:tenant) }

    context 'with booking_agent' do
      let(:booking_agent) { create(:booking_agent, organisation:) }
      let!(:agent_booking) { create(:agent_booking, booking:, booking_agent_code: booking_agent.code) }

      it { expect(transitioned_booking).to notify(:open_booking_agent_request_notification).to(:booking_agent) }
    end
  end
end
