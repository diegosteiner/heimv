FactoryGirl.define do
  factory :contract do
    booking
    title 'Mietvertrag'
    text 'Lorem Ipsum'

    trait :sent do
      sent_at { 1.week.ago }

      trait :signed do
        signed_at { 3.days.ago }
      end
    end
  end
end
