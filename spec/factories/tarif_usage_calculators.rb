FactoryBot.define do
  factory :tarif_usage_calculator do
    tarif { nil }
    usage_calculator { nil }
    role { 'MyString' }
    params { '' }
  end
end
