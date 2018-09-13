FactoryBot.define do
  factory :tarif, class: Tarifs::Amount.to_s do
    # type Tarifs::Amount
    label { 'Preis pro Übernachtung' }
    # transient false
    unit { 'Übernachtung (unter 16 Jahren)' }
    price_per_unit { 15.0 }
    home
    invoice_type { :invoice }
    prefill_usage_method { nil }

    trait :for_booking do
      booking
    end
  end
end
