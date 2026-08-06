# frozen_string_literal: true

# == Schema Information
#
# Table name: tarifs
#
#  id                                :bigint           not null, primary key
#  accounting_account_nr             :string
#  accounting_cost_center_nr         :string
#  associated_types                  :integer          default(0), not null
#  discarded_at                      :datetime
#  enabling_conditions               :jsonb
#  included_units                    :decimal(, )
#  included_units_mode               :integer          default(0)
#  label_i18n                        :jsonb
#  minimum                           :decimal(, )
#  minimum_mode                      :integer          default(0)
#  mode                              :integer
#  ordinal                           :integer
#  pin                               :boolean          default(TRUE)
#  prefill_usage_method              :string
#  price_per_unit                    :decimal(, )
#  selecting_conditions              :jsonb
#  tarif_group                       :string
#  type                              :string
#  unit_i18n                         :jsonb
#  valid_from                        :datetime
#  valid_until                       :datetime
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  organisation_id                   :bigint           not null
#  prefill_usage_booking_question_id :bigint
#  vat_category_id                   :bigint
#

FactoryBot.define do
  factory :tarif do
    type { Tarifs::Amount.sti_name }
    initialize_with { type.constantize.new }
    label { 'Tagesmiete' }
    unit { 'Tag' }
    price_per_unit { 150.0 }
    organisation
    associated_types { Tarif.associated_types.keys }
    prefill_usage_method { nil }

    trait :with_accounting do
      after(:build) do |tarif, _evaluator|
        tarif.accounting_account_nr ||= tarif.organisation.accounting_settings.rental_yield_account_nr || '6000'
        tarif.accounting_cost_center_nr ||= 'home'
      end
    end

    trait :amount do
      type { Tarifs::Amount.sti_name }
    end

    trait :price do
      type { Tarifs::Price.sti_name }
      label { 'Schaden' }
    end

    trait :metered do
      type { Tarifs::Metered.sti_name }
      unit { 'kWh' }
      label { 'Strom' }
      price_per_unit { 1.0 }
    end

    trait :overnight_stay do
      type { Tarifs::OvernightStay.sti_name }
      label { 'Übernachtung (unter 16 Jahren)' }
      unit { 'Übernachtung' }
      price_per_unit { 15.0 }
    end

    trait :group_minimum do
      type { Tarifs::GroupMinimum.sti_name }
      label { 'Minimum' }
      unit { 'Nacht' }
      minimum_usage_per_night { 10 }
      price_per_unit { 15.0 }
    end
  end
end
