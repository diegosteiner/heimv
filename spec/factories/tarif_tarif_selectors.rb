# == Schema Information
#
# Table name: tarif_tarif_selectors
#
#  id                :bigint(8)        not null, primary key
#  tarif_id          :bigint(8)
#  tarif_selector_id :bigint(8)
#  veto              :boolean          default(TRUE)
#  distinction       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

FactoryBot.define do
  factory :tarif_tarif_selector do
    tarif
    tarif_selector
    role { 'MyString' }
    params { '' }
  end
end
