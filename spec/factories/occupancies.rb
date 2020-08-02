# frozen_string_literal: true

# == Schema Information
#
# Table name: occupancies
#
#  id             :uuid             not null, primary key
#  begins_at      :datetime         not null
#  booking_type   :string
#  ends_at        :datetime         not null
#  occupancy_type :integer          default("free"), not null
#  remarks        :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  home_id        :bigint           not null
#
# Indexes
#
#  index_occupancies_on_begins_at       (begins_at)
#  index_occupancies_on_ends_at         (ends_at)
#  index_occupancies_on_home_id         (home_id)
#  index_occupancies_on_occupancy_type  (occupancy_type)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#

FactoryBot.define do
  factory :occupancy do
    begins_at { Time.zone.now + (2..10).to_a.sample.month }
    ends_at { begins_at + 1.week }
    occupancy_type { Occupancy.occupancy_types[:free] }
    home

    trait :occupied do
      occupancy_type { Occupancy.occupancy_types[:occupied] }
    end
  end
end
