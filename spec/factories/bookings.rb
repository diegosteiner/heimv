FactoryBot.define do
  factory :booking_transition do
    to_state { booking.initial_state }
    sort_key 0
    most_recent true
    booking
  end

  factory :booking do
    home
    association :customer, factory: :customer

    transient do
      initial_state :initial
    end

    after(:build) do |booking|
      booking.occupancy ||= build(:occupancy, home: booking.home)
    end

    after(:create) do |booking, evaluator|
      if evaluator.initial_state != :initial
        create(:booking_transition, booking: booking, to_state: evaluator.initial_state)
      end
    end
  end
end
