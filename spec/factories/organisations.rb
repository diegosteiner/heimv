FactoryBot.define do
  factory :organisation do
    name { "Heimverein St. Georg" }
    address { "MyText" }
    booking_strategy_type { BookingStrategies::Default.to_s }
    invoice_ref_strategy_type { InvoiceRefStrategies::ESR.to_s }
    payment_information { "MyString" }
    account_nr { "MyString" }
  end
end
