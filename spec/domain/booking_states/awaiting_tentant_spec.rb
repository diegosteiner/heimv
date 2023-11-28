# frozen_string_literal: true

require 'rails_helper'

describe BookingStates::AwaitingTenant do
  booking_flow_class = Class.new(BookingFlows::Base) do
    state BookingStates::Initial, to: [:awaiting_tenant], initial: true
    state BookingStates::AwaitingTenant
  end
  let(:organisation) { create(:organisation, :with_templates, booking_flow_class:) }
  let(:booking_agent) { create(:booking_agent, organisation:) }
  let!(:agent_booking) { create(:agent_booking, booking:, booking_agent_code: booking_agent.code) }
  subject(:booking) { create(:booking, organisation:, committed_request: false) }
  subject(:transition) { booking.booking_flow.transition_to(described_class.to_sym) }
  subject(:transitioned_booking) do
    booking.booking_flow.transition_to(described_class.to_sym)
    booking
  end

  describe 'transition' do
    it { expect(transitioned_booking.booking_state).to(be_a(described_class)) }
    it { expect(transitioned_booking.deadline).not_to be(nil) }
    it { expect(transitioned_booking).to be_occupied }

    it { expect(transitioned_booking).to notify(:awaiting_tenant_notification).to(:tenant) }
    it { expect(transitioned_booking).to notify(:booking_agent_request_accepted_notification).to(:booking_agent) }
  end
end
