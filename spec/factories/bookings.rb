# frozen_string_literal: true

# == Schema Information
#
# Table name: bookings
#
#  id                     :uuid             not null, primary key
#  approximate_headcount  :integer
#  booking_flow_type      :string
#  booking_state_cache    :string           default("initial"), not null
#  cancellation_reason    :text
#  color                  :string
#  committed_request      :boolean
#  concluded              :boolean          default(FALSE)
#  conditions_accepted_at :datetime
#  editable               :boolean          default(TRUE)
#  email                  :string
#  import_data            :jsonb
#  internal_remarks       :text
#  invoice_address        :text
#  locale                 :string
#  notifications_enabled  :boolean          default(FALSE)
#  purpose_description    :string
#  ref                    :string
#  remarks                :text
#  state_data             :json
#  tenant_organisation    :string
#  token                  :string
#  usages_entered         :boolean          default(FALSE)
#  usages_presumed        :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  booking_category_id    :integer
#  deadline_id            :bigint
#  home_id                :bigint           not null
#  organisation_id        :bigint           not null
#  tenant_id              :integer
#
# Indexes
#
#  index_bookings_on_booking_state_cache  (booking_state_cache)
#  index_bookings_on_deadline_id          (deadline_id)
#  index_bookings_on_home_id              (home_id)
#  index_bookings_on_locale               (locale)
#  index_bookings_on_organisation_id      (organisation_id)
#  index_bookings_on_ref                  (ref)
#  index_bookings_on_token                (token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (organisation_id => organisations.id)
#

FactoryBot.define do
  factory :booking do
    sequence(:email) { |n| "booking-#{n}@heimverwaltung.example.com" }

    home
    tenant_organisation { Faker::Company.name }
    committed_request { [true, false].sample }
    approximate_headcount { rand(1..30) }
    notifications_enabled { true }
    purpose_description { 'Pfadilager Test' }
    skip_infer_transitions { true }
    transient do
      initial_state { nil }
      begins_at { nil }
      ends_at { nil }
      occupancy { association :occupancy, home: home, occupancy_type: :free }
      tenant { association :tenant, organisation: organisation, email: email }
    end

    after(:build) do |booking, evaluator|
      # booking.organisation ||= booking.occupancy.organisation || booking.tenant.organisation
      booking.tenant = evaluator.tenant if evaluator.tenant.present?
      booking.occupancy = evaluator.occupancy if evaluator.occupancy.present?
      booking.occupancy.begins_at = evaluator.begins_at if evaluator.begins_at.present?
      booking.occupancy.ends_at = evaluator.ends_at if evaluator.ends_at.present?
      booking.category ||= booking.organisation.booking_categories.sample
    end

    after(:create) do |booking, evaluator|
      Booking::StateTransition.initial_for(booking, evaluator.initial_state) if evaluator.initial_state.present?
      booking.apply_transitions
    end
  end
end
