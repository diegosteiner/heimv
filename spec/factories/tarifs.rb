# frozen_string_literal: true

# == Schema Information
#
# Table name: tarifs
#
#  id                   :bigint           not null, primary key
#  accountancy_account  :string
#  invoice_types        :integer          default(0), not null
#  label_i18n           :jsonb
#  ordinal              :integer
#  pin                  :boolean          default(TRUE)
#  prefill_usage_method :string
#  price_per_unit       :decimal(, )
#  tarif_group          :string
#  tenant_visible       :boolean          default(TRUE)
#  type                 :string
#  unit_i18n            :jsonb
#  valid_from           :datetime
#  valid_until          :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  booking_id           :uuid
#  home_id              :bigint
#
# Indexes
#
#  index_tarifs_on_booking_id  (booking_id)
#  index_tarifs_on_home_id     (home_id)
#  index_tarifs_on_type        (type)
#

FactoryBot.define do
  factory :tarif, class: Tarifs::Amount.to_s do
    # type Tarifs::Amount
    label { 'Preis pro Übernachtung' }
    unit { 'Übernachtung (unter 16 Jahren)' }
    price_per_unit { 15.0 }
    home
    invoice_types { Tarif.invoice_types.keys }
    prefill_usage_method { nil }
  end
end
