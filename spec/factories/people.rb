FactoryGirl.define do
  factory :person do
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    street_address { Faker::Address.street_address }
    zipcode { Faker::Address.zip_code }
    city { Faker::Address.city }
  end
end
