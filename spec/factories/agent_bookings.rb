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

FactoryBot.define do
  factory :agent_booking do
    booking
    committed_request { false }
    accepted_request { false }

    after(:build) do |agent_booking, _evaluator|
      agent_booking.organisation ||= agent_booking.booking.organisation || build(:organisation)
      # agent_booking.home ||= agent_booking.booking.home
      # agent_booking.booking_agent ||= build(:booking_agent, organisation: agent_booking.organisation)
    end
  end
end
