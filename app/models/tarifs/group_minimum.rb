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
  class GroupMinimum < Tarif
    Tarif.register_subtype self

    class Usage < ::Usage
      def breakdown
        minimum = case tarif.minimum_mode.to_sym
                  when :usage_total, :usage_per_night, :usage_per_day
                    format_units(tarif.minimum)
                  when :price_total, :price_per_night, :price_per_day
                    format_price(tarif.minimum)
                  end

        I18n.t(tarif.minimum_mode, scope: 'invoice_items.breakdown.group_minimum',
                                   unit:, minimum:, difference: format_price(price),
                                   tarif_group_price: format_price(tarif_group_price),
                                   price_per_unit: format_price(price_per_unit))
      end

      def usages_in_tarif_group
        booking.usages.joins(:tarif)
               .where(tarifs: { tarif_group: tarif.tarif_group })
               .where.not(id:)
               .where.not(tarifs: { type: Tarifs::GroupMinimum.sti_name })
      end

      def tarif_group_used_units
        @tarif_group_used_units ||= usages_in_tarif_group.sum { it.used_units || 0 }
      end

      def tarif_group_price
        @tarif_group_price ||= usages_in_tarif_group.sum(&:price)
      end

      def minimum_price
        return if tarif.minimum_none? || super.blank?

        case tarif.minimum_mode.to_sym
        when :usage_per_night?, :usage_per_day?, :minimum_usage_total
          [(minimum_units - tarif_group_used_units) * price_per_unit, 0].max
        when :price_per_night?, :price_per_day?, :minimum_price_total
          [super - tarif_group_price, 0].max
        else
          0
        end
      end

      def apply_to_invoice?(_invoice)
        super && price.positive?
      end

      def prefill_units
        0
      end
    end
  end
end
