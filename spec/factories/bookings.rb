FactoryBot.define do
  factory :booking do
    home
    tenant
    organisation { Faker::Company.name }
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
