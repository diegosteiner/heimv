# frozen_string_literal: true

# == Schema Information
#
# Table name: agent_bookings
#
#  id                 :uuid             not null, primary key
#  booking_id         :uuid
#  booking_agent_code :string
#  booking_agent_ref  :string
#  committed_request  :boolean
#  accepted_request   :boolean
#  remarks            :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  organisation_id    :integer
#  tenant_email       :string
#  booking_agent_id   :integer          not null
#  token              :string
#  tenant_infos       :text
#
# Indexes
#
#  index_agent_bookings_on_booking_agent_id  (booking_agent_id)
#  index_agent_bookings_on_booking_id        (booking_id)
#  index_agent_bookings_on_organisation_id   (organisation_id)
#  index_agent_bookings_on_token             (token) UNIQUE
#

require 'rails_helper'

RSpec.describe AgentBooking, type: :model do
  describe '#assign_booking_agent' do
    let(:organisation) { create(:organisation) }
    let(:booking) { create(:booking, organisation:) }
    let(:agent_booking) { build(:agent_booking, booking:) }
    let(:booking_agent) { create(:booking_agent, organisation: booking.organisation, code: 'CODE123') }

    it do
      agent_booking.booking_agent_code = booking_agent.code
      expect(agent_booking.save).to eq(true)
      expect(agent_booking.booking_agent).to eq(booking_agent)
    end
  end
end
