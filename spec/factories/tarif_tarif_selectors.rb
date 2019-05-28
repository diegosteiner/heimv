# == Schema Information
#
# Table name: tarif_tarif_selectors
#
#  id                :bigint           not null, primary key
#  tarif_id          :bigint
#  tarif_selector_id :bigint
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
