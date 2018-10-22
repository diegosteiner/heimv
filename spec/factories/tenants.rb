FactoryBot.define do
  factory :tenant do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    street_address { Faker::Address.street_address }
    zipcode { Faker::Address.zip_code }
    city { Faker::Address.city }
    email do |c|
      "#{[c.first_name, c.last_name].join('.').downcase.sub(/[^a-z_\.\d]/i, '')}@heimverwaltung.example.com"
    end
  end
end
