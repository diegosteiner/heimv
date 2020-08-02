# frozen_string_literal: true

# == Schema Information
#
# Table name: usages
#
#  id                  :bigint           not null, primary key
#  presumed_used_units :decimal(, )
#  remarks             :text
#  used_units          :decimal(, )
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  booking_id          :uuid
#  tarif_id            :bigint
#
# Indexes
#
#  index_usages_on_booking_id               (booking_id)
#  index_usages_on_tarif_id_and_booking_id  (tarif_id,booking_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (tarif_id => tarifs.id)
#

FactoryBot.define do
  factory :usage do
    association :tarif, :for_booking
    used_units { 9.99 }
    remarks { 'Test' }
    booking { tarif.booking }
  end
end
