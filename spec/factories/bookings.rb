# == Schema Information
#
# Table name: bookings
#
#  id                    :uuid             not null, primary key
#  home_id               :bigint(8)        not null
#  state                 :string           default("initial"), not null
#  tenant_organisation          :string
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
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  booking_agent_code    :string
#

FactoryBot.define do
  factory :booking do
    home
    tenant
    tenant_organisation { Faker::Company.name }
    sequence(:email) { |n| "booking-#{n}@heimverwaltung.example.com" }
    skip_automatic_transition { initial_state_present? }
    committed_request { [true, false].sample }
    approximate_headcount { rand(30) }
    purpose { :camp }

    transient do
      initial_state { :initial }
      initial_state_present? { ![nil, :initial].include?(initial_state) }
      initial_occupancy_type { :free }
    end

    after(:build) do |booking|
      booking.occupancy ||= build(:occupancy, home: booking.home, occupancy_type: :free)
    end

    after(:create) do |booking, evaluator|
      if evaluator.initial_state_present?
        create(:booking_transition, booking: booking, to_state: evaluator.initial_state)
        # create(:deadline, booking: booking)
      end
    end
  end
end
