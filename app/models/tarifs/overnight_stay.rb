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
#  label_i18n                        :jsonb
#  minimum_price_per_night           :decimal(, )
#  minimum_price_total               :decimal(, )
#  minimum_usage_per_night           :decimal(, )
#  minimum_usage_total               :decimal(, )
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

module Tarifs
  class OvernightStay < ::Tarif
    Tarif.register_subtype self

    def before_usage_validation(usage)
      set_usage_details(usage)
      set_usage_used_units(usage)
    end

    def set_usage_details(usage) # rubocop:disable Naming/AccessorMethodName
      booking_dates = usage.booking.dates.map(&:iso8601)
      usage.details = usage.details&.slice(*booking_dates)&.transform_values { it.presence&.to_f } || {}
    end

    def set_usage_used_units(usage) # rubocop:disable Naming/AccessorMethodName
      return unless usage.details.present? && (usage.details_changed? || usage.used_units.blank?)

      usage.used_units = usage.details.values.compact.sum
    end
  end
end
