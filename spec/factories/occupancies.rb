FactoryBot.define do
  factory :occupancy do
    begins_at { Time.zone.now + (1..10).to_a.sample.month }
    ends_at { begins_at + 1.week }
    occupancy_type { Occupancy.occupancy_types[:occupied] }
    home
  end
end
