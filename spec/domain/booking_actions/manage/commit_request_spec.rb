# frozen_string_literal: true

require 'rails_helper'

describe BookingActions::Manage::CommitRequest do
  subject(:action) { described_class.new(booking:) }

  let(:booking) { create(:booking, initial_state:, committed_request: false) }
  let(:initial_state) { :provisional_request }

  describe '#call!' do
    subject(:call) { described_class.call(booking:) }

    it { expect(call.ok).to be_truthy }
    it do
      call
      expect(booking.committed_request).to be_truthy
    end
  end
end
