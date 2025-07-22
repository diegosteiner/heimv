# frozen_string_literal: true

# == Schema Information
#
# Table name: agent_bookings
#
#  id                 :uuid             not null, primary key
#  accepted_request   :boolean
#  booking_agent_code :string
#  booking_agent_ref  :string
#  committed_request  :boolean
#  remarks            :text
#  tenant_email       :string
#  tenant_infos       :text
#  token              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  booking_agent_id   :bigint           not null
#  booking_id         :uuid
#  organisation_id    :bigint
#

require 'rails_helper'

RSpec.describe AgentBooking do
  describe '#assign_booking_agent' do
    let(:organisation) { create(:organisation) }
    let(:booking) { create(:booking, organisation:) }
    let(:agent_booking) { build(:agent_booking, booking:) }
    let(:booking_agent) { create(:booking_agent, organisation: booking.organisation, code: 'CODE123') }

    it do
      agent_booking.booking_agent_code = booking_agent.code
      expect(agent_booking.save).to be(true)
      expect(agent_booking.booking_agent).to eq(booking_agent)
    end
  end
end
