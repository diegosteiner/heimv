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

module Tarifs
  class Price < Tarif
    Tarif.register_subtype self

    class Usage < ::Usage
      def prefill_units
        tarif.price_per_unit.presence
      end

      def price_per_unit
        nil
      end

      def price(units: nil, minimum_price: self.minimum_price, price_per_unit: nil)
        super(units: 1, minimum_price:, price_per_unit: billable_units)
      end

      def breakdown
        return if used_units.nil?

        format_price(billable_units)
      end
    end
  end
end
