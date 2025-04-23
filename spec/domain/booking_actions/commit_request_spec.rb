# frozen_string_literal: true

require 'rails_helper'

describe BookingActions::CommitRequest do
  subject(:action) { described_class.new(booking, :commit_request) }

  let(:booking) { create(:booking, initial_state:, committed_request: false) }
  let(:initial_state) { :provisional_request }
  let(:current_user) { create(:organisation_user, organisation: booking.organisation, role: :manager) }

  describe '#invoke' do
    subject(:invoke) { action.invoke(current_user:) }

    it { expect(invoke.success).to be_truthy }

    it do
      invoke
      expect(booking.committed_request).to be_truthy
    end
  end
end
