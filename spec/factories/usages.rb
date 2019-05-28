# == Schema Information
#
# Table name: usages
#
#  id         :bigint           not null, primary key
#  tarif_id   :bigint
#  used_units :decimal(, )
#  remarks    :text
#  booking_id :uuid
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :usage do
    tarif
    used_units { '9.99' }
    remarks { 'Test' }
    booking { tarif.booking }
  end
end
