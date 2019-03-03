# == Schema Information
#
# Table name: occupancies
#
#  id             :uuid             not null, primary key
#  begins_at      :datetime         not null
#  ends_at        :datetime         not null
#  home_id        :bigint(8)        not null
#  booking_type   :string
#  booking_id     :uuid
#  occupancy_type :integer          default("free"), not null
#  remarks        :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryBot.define do
  factory :occupancy do
    begins_at { Time.zone.now + (1..10).to_a.sample.month }
    ends_at { begins_at + 1.week }
    occupancy_type { Occupancy.occupancy_types[:free] }
    home

    trait :occupied do
      occupancy_type { Occupancy.occupancy_types[:occupied] }
    end
  end
end
