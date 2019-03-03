# == Schema Information
#
# Table name: invoices
#
#  id                 :bigint(8)        not null, primary key
#  booking_id         :uuid
#  issued_at          :datetime
#  payable_until      :datetime
#  sent_at            :datetime
#  text               :text
#  invoice_type       :integer
#  esr_number         :string
#  amount             :decimal(, )      default(0.0)
#  paid               :boolean          default(FALSE)
#  print_payment_slip :boolean          default(FALSE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

FactoryBot.define do
  factory :invoice do
    booking
    esr_number { Faker::Bank.iban }
    issued_at { 1.week.ago }
    payable_until { 3.months.from_now }
    text { Faker::Lorem.sentences(3) }
    invoice_type { :invoice }
  end
end
