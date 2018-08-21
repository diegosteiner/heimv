FactoryBot.define do
  factory :booking_transition do
    to_state { booking.initial_state || :initial }
    sort_key { 0 }
    most_recent { true }
    booking
  end
end
