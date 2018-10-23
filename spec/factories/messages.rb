FactoryBot.define do
  factory :message do
    body { "MyText" }
    sent_at { "2018-10-23 14:08:21" }
    subject { "MyString" }
    booking { nil }
  end
end
