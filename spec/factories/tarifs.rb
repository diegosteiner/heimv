# == Schema Information
#
# Table name: tarifs
#
#  id                       :bigint           not null, primary key
#  type                     :string
#  label                    :string
#  transient                :boolean          default(FALSE)
#  booking_id               :uuid
#  home_id                  :bigint
#  booking_copy_template_id :bigint
#  unit                     :string
#  price_per_unit           :decimal(, )
#  valid_from               :datetime
#  valid_until              :datetime
#  position                 :integer
#  tarif_group              :string
#  invoice_type             :string
#  prefill_usage_method     :string
#  meter                    :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

FactoryBot.define do
  factory :tarif, class: Tarifs::Amount.to_s do
    # type Tarifs::Amount
    label { 'Preis pro Übernachtung' }
    # transient false
    unit { 'Übernachtung (unter 16 Jahren)' }
    price_per_unit { 15.0 }
    home
    invoice_type { :invoice }
    prefill_usage_method { nil }

    trait :for_booking do
      booking
    end
  end
end
