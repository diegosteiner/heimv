# frozen_string_literal: true

require 'rails_helper'

describe BookingActions::MarkContractSent do
  subject(:action) { described_class.new(booking, :mark_contract_sent) }
  subject(:invoke) { action.invoke }
  subject(:booking_after_invoke) do
    invoke
    booking
  end

  let(:organisation) { create(:organisation, :with_templates) }
  let(:booking) { create(:booking, organisation:, initial_state:) }
  let(:initial_state) { :definitive_request }
  let!(:contract) { create(:contract, booking:) }

  describe '#invokable?' do
    subject(:allowed) { action.invokable? }

    it { expect(allowed).to be_truthy }
  end

  describe '#invoke' do
    it { expect(invoke.success).to be_truthy }
    it { expect(booking_after_invoke).to notify(:contract_sent_notification).to(:tenant) }
    it { expect(booking_after_invoke.contract).to be_sent }
  end
end
