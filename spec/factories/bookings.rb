FactoryBot.define do
  factory :booking do
    home
    association :customer, factory: :customer
    organisation { Faker::Company.name }
    email { Faker::Internet.safe_email }
    skip_automatic_transition { initial_state_present? }
    committed_request { true }
    approximate_headcount { rand(30) }
    purpose { :camp }

    transient do
      initial_state { :initial }
      initial_state_present? { ![nil, :initial].include?(initial_state) }
    end

    after(:build) do |booking|
      booking.occupancy ||= build(:occupancy, home: booking.home)
    end

    after(:create) do |booking, evaluator|
      if evaluator.initial_state_present?
        create(:booking_transition, booking: booking, to_state: evaluator.initial_state)
        create(:deadline, booking: booking)
      end
    end
  end
end
