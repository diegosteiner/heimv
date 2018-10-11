FactoryBot.define do
  factory :meter_reading do
    at { "2018-10-10 20:54:45" }
    usage { nil }
    value { "9.99" }
    home { nil }
    meter_name { "MyString" }
  end
end
