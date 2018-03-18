FactoryBot.define do
  factory :home do
    name { "Pfadiheim #{Faker::Address.city}" }
    sequence(:ref) { |i| "#{name.downcase.delete('aeiuoäöü ./:;?!()')}#{i}" }
  end
end
