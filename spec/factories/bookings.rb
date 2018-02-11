FactoryBot.define do
  factory :booking do
    home
    association :customer, factory: :customer
    organisation { Faker::Company.name }
    email { Faker::Internet.safe_email }

    transient do
      initial_state :initial
    end

    after(:build) do |booking|
      booking.occupancy ||= build(:occupancy, home: booking.home)
    end

    after(:create) do |booking, evaluator|
      unless [nil, :initial].include?(evaluator.initial_state)
        create(:booking_transition, booking: booking, to_state: evaluator.initial_state)
      end
    end
  end
end
