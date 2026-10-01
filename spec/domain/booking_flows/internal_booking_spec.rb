# frozen_string_literal: true

require 'rails_helper'

describe BookingFlows::InternalBooking do
  subject(:booking_flow) { described_class.new(booking) }

  let(:organisation) { create(:organisation, :with_templates) }
  let(:home) { create(:home, organisation:) }
  let(:booking) { create(:booking, organisation:, home:, skip_infer_transitions: true) }

  before { allow(organisation).to receive(:booking_flow_class).and_return(described_class) }

  describe 'transition path' do
    it { is_expected.to transition_to(:open_request).from(:initial) }
    it { is_expected.to transition_to(:upcoming).from(:open_request) }
    it { is_expected.to transition_to(:upcoming_soon).from(:upcoming) }
    it { is_expected.to transition_to(:active).from(:upcoming_soon) }
    it { is_expected.to transition_to(:completed).from(:active) }

    it { is_expected.not_to transition_to(:definitive_request).from(:open_request) }
    it { is_expected.not_to transition_to(:cancelation_pending).from(:active) }
  end
end
