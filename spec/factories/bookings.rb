# == Schema Information
#
# Table name: bookings
#
#  id                    :uuid             not null, primary key
#  home_id               :bigint           not null
#  organisation_id       :bigint           not null
#  state                 :string           default("initial"), not null
#  tenant_organisation   :string
#  email                 :string
#  tenant_id             :integer
#  state_data            :json
#  committed_request     :boolean
#  cancellation_reason   :text
#  approximate_headcount :integer
#  remarks               :text
#  invoice_address       :text
#  purpose               :string
#  ref                   :string
#  editable              :boolean          default(TRUE)
#  usages_entered        :boolean          default(FALSE)
#  messages_enabled      :boolean          default(FALSE)
#  import_data           :jsonb
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  booking_agent_code    :string
#  booking_agent_ref     :string
#

FactoryBot.define do
  factory :booking do
    home
    tenant
    tenant_organisation { Faker::Company.name }
    sequence(:email) { |n| "booking-#{n}@heimverwaltung.example.com" }
    skip_automatic_transition { true }
    committed_request { [true, false].sample }
    approximate_headcount { rand(30) }
    purpose { :camp }

    after(:build) do |booking|
      booking.organisation ||= booking.home.organisation
      booking.occupancy ||= build(:occupancy, home: booking.home, occupancy_type: :free)
    end
  end
end
