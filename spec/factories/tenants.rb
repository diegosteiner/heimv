# == Schema Information
#
# Table name: tenants
#
#  id                   :bigint           not null, primary key
#  first_name           :string
#  last_name            :string
#  street_address       :string
#  zipcode              :string
#  city                 :string
#  country              :string
#  reservations_allowed :boolean
#  email_verified       :boolean          default(FALSE)
#  phone                :text
#  remarks              :text
#  email                :string           not null
#  search_cache         :text             not null
#  birth_date           :date
#  import_data          :jsonb
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

FactoryBot.define do
  factory :tenant do
    organisation
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    street_address { Faker::Address.street_address }
    zipcode { Faker::Address.zip_code }
    city { Faker::Address.city }
    birth_date { 22.years.ago.to_date }
    email do |c|
      "#{[c.first_name, c.last_name].join('.').downcase.sub(/[^a-z_\.\d]/i, '')}@heimverwaltung.example.com"
    end
  end
end
