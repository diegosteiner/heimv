FactoryBot.define do
  factory :tarif do
    # type nil
    label 'Preis pro Übernachtung'
    appliable true
    unit 'Übernachtung (unter 16 Jahren)'
    price_per_unit 15.0
  end
end
