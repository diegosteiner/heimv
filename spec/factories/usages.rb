# frozen_string_literal: true

# == Schema Information
#
# Table name: usages
#
#  id             :bigint           not null, primary key
#  committed      :boolean          default(FALSE)
#  details        :jsonb
#  price_per_unit :decimal(, )
#  quoted_units   :decimal(, )
#  remarks        :text
#  type           :string           not null
#  used_units     :decimal(, )
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  booking_id     :uuid
#  tarif_id       :bigint
#

FactoryBot.define do
  factory :usage do
    tarif { association :tarif, organisation: booking.organisation }
    used_units { 9.99 }
    remarks { 'Remarks' }
    booking

    after(:build) do |usage, _evaluator|
      usage.assert_usage_type!
    end
  end
end
