# frozen_string_literal: true

# == Schema Information
#
# Table name: occupiables
#
#  id               :bigint           not null, primary key
#  description_i18n :jsonb
#  discarded_at     :datetime
#  janitor          :text
#  name_i18n        :jsonb
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
# Indexes
#
#  index_occupiables_on_discarded_at             (discarded_at)
#  index_occupiables_on_home_id                  (home_id)
#  index_occupiables_on_organisation_id          (organisation_id)
#  index_occupiables_on_ref_and_organisation_id  (ref,organisation_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

FactoryBot.define do
  factory :occupiable do
    organisation
    name { "Pfadiheim #{Faker::Address.city}" }
    description { "#{Faker::Address.zip_code} #{Faker::Address.city}" }
    sequence(:ref) { |i| "H#{i}" }
    occupiable { true }

    factory :home, class: 'Home'
  end
end
