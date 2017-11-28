FactoryBot.define do
  factory :occupancy do
    begins_at { Time.zone.now + 1.month }
    ends_at { begins_at + 1.week }
    blocking false
    home
  end
end
