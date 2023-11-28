# frozen_string_literal: true

require 'rails_helper'

describe BookingActions::Manage::MarkContractSent do
  subject(:action) { described_class.new(booking:) }
  subject(:call) { described_class.call(booking:) }
  subject(:booking_after_call) do
    call
    booking
  end

  let(:organisation) { create(:organisation, :with_templates) }
  let(:booking) { create(:booking, organisation:, initial_state:) }
  let(:initial_state) { :definitive_request }
  let!(:contract) { create(:contract, booking:) }

  describe '#allowed?' do
    subject(:allowed) { action.allowed? }

    it { expect(allowed).to be_truthy }
  end

  describe '#call!' do
    it { expect(call.ok).to be_truthy }
    it { expect(booking_after_call).to notify(:contract_sent_notification).to(:tenant) }
    it { expect(booking_after_call.contract).to be_sent }
  end
end
