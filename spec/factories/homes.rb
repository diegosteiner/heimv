FactoryBot.define do
  factory :home do
    name { "Pfadiheim #{Faker::Address.city}" }
    place { "#{Faker::Address.zip_code} #{Faker::Address.city}" }
    sequence(:ref) { |i| "#{name.downcase.delete('aeiuoäöü ./:;?!()')}#{i}" }
  end
end
