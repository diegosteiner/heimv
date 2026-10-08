# frozen_string_literal: true

require 'rails_helper'

describe BookingActions::Decline do
  subject(:action) { described_class.new(booking, :decline) }

  let(:initial_state) { :waitlisted_request }
  let(:booking) { create(:booking, organisation:, initial_state:, committed_request: false, home: occupiable) }
  let(:organisation) { create(:organisation) }
  let(:occupiable) { create(:home, organisation:) }
  let(:current_user) { create(:organisation_user, organisation:, role: :manager) }
  let(:existing_booking) do
    create(:booking, initial_state: :upcoming, committed_request: true, occupancy_status: :occupied, organisation:,
                     begins_at: booking.begins_at, ends_at: booking.ends_at, home: occupiable)
  end

  describe '#invoke' do
    subject(:invoke) { action.invoke(current_user:) }

    before do
      organisation.update!(booking_state_settings: { enable_waitlist: true })
      existing_booking
    end

    it do
      expect(booking).to be_status_pending
      expect(booking.conflicting(assuming: :any)).to include(existing_booking)
      expect(invoke.success).to be_truthy
      expect(booking).to be_status_void
    end
  end
end
