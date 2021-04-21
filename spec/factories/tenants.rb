# frozen_string_literal: true

# == Schema Information
#
# Table name: tenants
#
#  id                   :bigint           not null, primary key
#  birth_date           :date
#  city                 :string
#  country_code         :string           default("CH")
#  email                :string
#  email_verified       :boolean          default(FALSE)
#  first_name           :string
#  import_data          :jsonb
#  last_name            :string
#  phone                :text
#  remarks              :text
#  reservations_allowed :boolean          default(TRUE)
#  search_cache         :text             not null
#  street_address       :string
#  zipcode              :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  organisation_id      :bigint           not null
#
# Indexes
#
#  index_tenants_on_email                      (email)
#  index_tenants_on_email_and_organisation_id  (email,organisation_id) UNIQUE
#  index_tenants_on_organisation_id            (organisation_id)
#  index_tenants_on_search_cache               (search_cache)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
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
    phone { '044 444 44 44' }
    email do |c|
      "#{[c.first_name, c.last_name].join('.').downcase.sub(/[^a-z_.\d]/i, '')}@heimverwaltung.example.com"
    end
  end
end
