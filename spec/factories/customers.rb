FactoryBot.define do
  factory :customer do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    street_address { Faker::Address.street_address }
    zipcode { Faker::Address.zip_code }
    city { Faker::Address.city }
    email { |c| "#{c.first_name}.#{c.last_name}@heimverwaltung.example.com".underscore.downcase }
  end
end
