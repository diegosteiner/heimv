# frozen_string_literal: true

# == Schema Information
#
# Table name: bookings
#
#  id                    :uuid             not null, primary key
#  approximate_headcount :integer
#  cancellation_reason   :text
#  committed_request     :boolean
#  concluded             :boolean          default(FALSE)
#  editable              :boolean          default(TRUE)
#  email                 :string
#  import_data           :jsonb
#  internal_remarks      :text
#  invoice_address       :text
#  messages_enabled      :boolean          default(FALSE)
#  purpose               :string
#  ref                   :string
#  remarks               :text
#  state                 :string           default("initial"), not null
#  state_data            :json
#  tenant_organisation   :string
#  timeframe_locked      :boolean          default(FALSE)
#  usages_entered        :boolean          default(FALSE)
#  usages_presumed       :boolean          default(FALSE)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  deadline_id           :bigint
#  home_id               :bigint           not null
#  occupancy_id          :uuid
#  organisation_id       :bigint           not null
#  tenant_id             :integer
#
# Indexes
#
#  index_bookings_on_deadline_id      (deadline_id)
#  index_bookings_on_home_id          (home_id)
#  index_bookings_on_organisation_id  (organisation_id)
#  index_bookings_on_ref              (ref)
#  index_bookings_on_state            (state)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (organisation_id => organisations.id)
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
