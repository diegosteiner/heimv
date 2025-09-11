# frozen_string_literal: true

require 'rails_helper'

describe BookingActions::Decline do
  subject(:action) { described_class.new(booking, :decline) }

  let(:initial_state) { :waitlisted_request }
  let(:booking) { create(:booking, initial_state:, committed_request: false, occupiables: [occupiable]) }
  let(:organisation) { create(:organisation) }
  let(:occupiable) { create(:occupiable, organisation:) }
  let(:current_user) { create(:organisation_user, organisation:, role: :manager) }

  describe '#invoke' do
    subject(:invoke) { action.invoke(current_user:) }

    before do
      organisation.booking_state_settings.enable_waitlist = true
      create(:booking, initial_state: :upcoming, committed_request: true, occupancy_type: :occupied,
                       begins_at: booking.begins_at, ends_at: booking.ends_at, occupiables: [occupiable])
    end

    it do
      expect(booking).to be_pending
      expect(booking).to be_conflicting
      expect(invoke.success).to be_truthy
      expect(booking).to be_free
    end
  end
end
