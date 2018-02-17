FactoryBot.define do
  factory :booking do
    home
    association :customer, factory: :customer
    organisation { Faker::Company.name }
    email { Faker::Internet.safe_email }
    skip_automatic_transition { ![nil, :initial].include?(initial_state) }
    defintive_request { false }

    transient do
      initial_state :initial
    end

    after(:build) do |booking|
      booking.occupancy ||= build(:occupancy, home: booking.home)
    end

    after(:create) do |booking, evaluator|
      if booking.skip_automatic_transition
        create(:booking_transition, booking: booking, to_state: evaluator.initial_state)
      end
    end
  end
end
