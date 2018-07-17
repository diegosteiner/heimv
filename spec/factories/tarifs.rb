FactoryBot.define do
  factory :tarif do
    # type nil
    label 'Preis pro Übernachtung'
    # transient false
    unit 'Übernachtung (unter 16 Jahren)'
    price_per_unit 15.0

    trait :for_home do
      home
    end

    trait :for_booking do
      booking
    end
  end
end
