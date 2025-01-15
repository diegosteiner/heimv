# frozen_string_literal: true

# == Schema Information
#
# Table name: usages
#
#  id                  :bigint           not null, primary key
#  committed           :boolean          default(FALSE)
#  details             :jsonb
#  presumed_used_units :decimal(, )
#  price_per_unit      :decimal(, )
#  remarks             :text
#  used_units          :decimal(, )
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  booking_id          :uuid
#  tarif_id            :bigint
#

FactoryBot.define do
  factory :usage do
    tarif { association :tarif, organisation: booking.organisation }
    used_units { 9.99 }
    remarks { 'Remarks' }
    booking
  end
end
