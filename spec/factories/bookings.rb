FactoryBot.define do
  factory :booking do
    home
    association :customer, factory: :customer

    after(:build) do |booking|
      booking.occupancy ||= create(:occupancy, home: booking.home)
    end
  end
end
