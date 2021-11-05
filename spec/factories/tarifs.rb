# frozen_string_literal: true

# == Schema Information
#
# Table name: tarifs
#
#  id                       :bigint           not null, primary key
#  invoice_type             :string
#  label_i18n               :jsonb
#  ordinal                  :integer
#  prefill_usage_method     :string
#  price_per_unit           :decimal(, )
#  tarif_group              :string
#  tenant_visible           :boolean          default(TRUE)
#  transient                :boolean          default(FALSE)
#  type                     :string
#  unit_i18n                :jsonb
#  valid_from               :datetime
#  valid_until              :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  booking_copy_template_id :bigint
#  booking_id               :uuid
#  home_id                  :bigint
#
# Indexes
#
#  index_tarifs_on_booking_copy_template_id  (booking_copy_template_id)
#  index_tarifs_on_booking_id                (booking_id)
#  index_tarifs_on_home_id                   (home_id)
#  index_tarifs_on_type                      (type)
#

FactoryBot.define do
  factory :tarif, class: Tarifs::Amount.to_s do
    # type Tarifs::Amount
    label { 'Preis pro Übernachtung' }
    unit { 'Übernachtung (unter 16 Jahren)' }
    price_per_unit { 15.0 }
    home
    invoice_type { Invoices::Invoice.to_s }
    prefill_usage_method { nil }

    trait :for_booking do
      booking
    end
  end
end
