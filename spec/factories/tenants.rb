# frozen_string_literal: true

# == Schema Information
#
# Table name: tenants
#
#  id                        :bigint           not null, primary key
#  accounting_account_nr     :string
#  address_addon             :string
#  birth_date                :date
#  bookings_without_contract :boolean          default(FALSE)
#  bookings_without_invoice  :boolean          default(FALSE)
#  city                      :string
#  country_code              :string           default("CH")
#  email                     :string
#  email_verified            :boolean          default(FALSE)
#  first_name                :string
#  import_data               :jsonb
#  last_name                 :string
#  locale                    :string
#  nickname                  :string
#  phone                     :text
#  ref                       :string
#  remarks                   :text
#  reservations_allowed      :boolean          default(TRUE)
#  salutation_form           :integer
#  search_cache              :text             not null
#  sequence_number           :integer
#  street                    :string
#  street_nr                 :string
#  zipcode                   :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  organisation_id           :bigint           not null
#

FactoryBot.define do
  factory :tenant do
    organisation
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    address_addon { Faker::Address.secondary_address }
    street { Faker::Address.street_name }
    street_nr { Faker::Address.building_number }
    zipcode { Faker::Address.zip_code }
    city { Faker::Address.city }
    birth_date { 22.years.ago.to_date }
    phone { '044 444 44 44' }
    locale { I18n.locale }
    sequence(:email) { |n| "tenant#{n}@heimv.test" }
  end
end
