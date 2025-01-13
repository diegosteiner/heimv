# frozen_string_literal: true

# == Schema Information
#
# Table name: occupiables
#
#  id               :bigint           not null, primary key
#  description_i18n :jsonb            not null
#  discarded_at     :datetime
#  janitor          :text
#  name_i18n        :jsonb            not null
#  occupiable       :boolean          default(FALSE)
#  ordinal          :integer
#  ref              :string
#  settings         :jsonb
#  type             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  home_id          :bigint
#  organisation_id  :bigint           not null
#

FactoryBot.define do
  factory :occupiable do
    organisation
    name { "Pfadiheim #{Faker::Address.city}" }
    description { "#{Faker::Address.zip_code} #{Faker::Address.city}" }
    sequence(:ref) { |i| "H#{i}" }
    occupiable { true }
    settings { { accounting_cost_center_nr: '9001' } }

    factory :home, class: 'Home'
  end
end
