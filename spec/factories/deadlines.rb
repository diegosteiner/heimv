FactoryBot.define do
  factory :deadline do
    at { 30.days.from_now }
    # booking { nil }
    # responsible { nil }
    extendable { 0 }
  end
end
