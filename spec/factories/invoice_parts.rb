FactoryBot.define do
  factory :invoice_part do
    invoice nil
    usage nil
    type ""
    amount "9.99"
    text "MyText"
    position 1
  end
end
