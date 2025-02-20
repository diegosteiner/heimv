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
#  enabling_condition                :jsonb
#  label_i18n                        :jsonb
#  minimum_price_per_night           :decimal(, )
#  minimum_price_total               :decimal(, )
#  minimum_usage_per_night           :decimal(, )
#  minimum_usage_total               :decimal(, )
#  ordinal                           :integer
#  pin                               :boolean          default(TRUE)
#  prefill_usage_method              :string
#  price_per_unit                    :decimal(, )
#  selecting_condition               :jsonb
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
    label { 'Preis pro Übernachtung' }
    unit { 'Übernachtung (unter 16 Jahren)' }
    price_per_unit { 15.0 }
    organisation
    associated_types { Tarif.associated_types.keys }
    prefill_usage_method { nil }

    trait :with_accounting do
      after(:build) do |tarif, _evaluator|
        tarif.accounting_account_nr ||= tarif.organisation.accounting_settings.rental_yield_account_nr || '6000'
        tarif.accounting_cost_center_nr ||= 'home'
      end
    end
  end
end
