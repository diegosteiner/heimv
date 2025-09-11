# frozen_string_literal: true

require 'rails_helper'

describe BookingActions::PutOnWaitlist, :pending do # rubocop:disable RSpec/PendingWithoutReason
  subject(:action) { described_class.new(booking, :put_on_waitlist) }

  let(:initial_state) { :open_request }
  let(:booking) { create(:booking, initial_state:, committed_request: false, occupiables: [occupiable]) }
  let(:organisation) { create(:organisation) }
  let(:occupiable) { create(:occupiable, organisation:) }
  let(:current_user) { create(:organisation_user, organisation:, role: :manager) }

  describe '#invoke' do
    subject(:invoke) { action.invoke(current_user:) }

    before do
      organisation.booking_state_settings.enable_waitlist = true
    end

    it do
      expect(booking).to be_pending
      # expect(invoke.error).to eq(nil)
      expect(invoke.success).to be_truthy
      expect(booking).to be_pending
      expect(booking.booking_flow.current_state).to eq(:waitlisted_request)
    end
  end
end
