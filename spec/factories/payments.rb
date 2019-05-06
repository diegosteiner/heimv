# == Schema Information
#
# Table name: payments
#
#  id         :bigint           not null, primary key
#  amount     :decimal(, )
#  paid_at    :date
#  ref        :string
#  invoice_id :bigint
#  booking_id :uuid
#  data       :text
#  remarks    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :payment do
    amount { '9.99' }
    paid_at { '2018-10-11' }
    data { 'MyText' }
  end
end
