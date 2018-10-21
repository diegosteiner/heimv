FactoryBot.define do
  factory :deadline do
    at { 30.days.from_now }
    # subject { nil }
    responsible { nil }
    extended { 0 }
  end
end
