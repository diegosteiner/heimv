FactoryBot.define do
  factory :organisation do
    sequence(:ref) { |i| "hv-#{i}" }
    name { "Heimverein" }
  end
end
