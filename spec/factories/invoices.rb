FactoryBot.define do
  factory :invoice do
    booking
    esr_number { Faker::Bank.iban }
    issued_at { 1.week.ago }
    payable_until { 3.months.from_now }
    text { Faker::Lorem.sentences(3) }
    # invoice_type 1
  end
end
