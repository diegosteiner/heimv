FactoryBot.define do
  factory :payment do
    amount { '9.99' }
    paid_at { '2018-10-11' }
    data { 'MyText' }
  end
end
