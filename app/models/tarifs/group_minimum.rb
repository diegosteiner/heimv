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
      def breakdown # rubocop:disable Metrics/AbcSize
        difference = number_to_currency(price || 0, unit: organisation.currency)
        tarif_group_price = number_to_currency(tarif_group_price || 0, unit: organisation.currency)
        minimum = case critical_minimum
                  when :minimum_usage_total, :minimum_usage_per_night
                    tarif.minimums[critical_minimum] || 0
                  when :minimum_price_total, :minimum_price_per_night
                    number_to_currency(tarif.minimums[critical_minimum] || 0, unit: organisation.currency)
                  end

        I18n.t(critical_minimum, scope: 'invoice_items.breakdown', unit:, minimum:, difference:, tarif_group_price:,
                                 price_per_unit: number_to_currency(price_per_unit, unit: organisation.currency))
      end

      def usages_in_tarif_group
        booking.usages.joins(:tarif)
               .where(tarifs: { tarif_group: tarif.tarif_group })
               .where.not(id:)
               .where.not(tarifs: { type: Tarifs::GroupMinimum.sti_name })
      end

      def tarif_group_price
        @tarif_group_price ||= usages_in_tarif_group.sum(&:price)
      end

      def tarif_group_used_units
        @tarif_group_used_units ||= usages_in_tarif_group.sum { it.used_units || 0 }
      end

      def minimum_prices_difference # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
        nights = booking&.nights || 0

        @minimum_prices_difference ||= {
          minimum_usage_per_night:
            tarif.minimum_usage_per_night&.*(nights)&.-(tarif_group_used_units)&.*(price_per_unit),
          minimum_usage_total: tarif.minimum_usage_total&.-(tarif_group_used_units)&.*(price_per_unit),
          minimum_price_per_night: tarif.minimum_price_per_night&.*(nights)&.-(tarif_group_price),
          minimum_price_total: tarif.minimum_price_total&.-(tarif_group_price)
        }
      end

      def minimum_price
        @minimum_price ||= if minimum_prices_difference.values.compact.all?(&:negative?)
                             minimum_prices_difference.values.compact.filter(&:negative?).min
                           else
                             minimum_prices_difference.values.compact.filter(&:positive?).max
                           end
      end

      def critical_minimum
        @critical_minimum ||= minimum_price.present? && minimum_prices_difference.find { minimum_price == _2 }&.first
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
