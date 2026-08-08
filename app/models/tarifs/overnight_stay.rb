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
  class OvernightStay < ::Tarif
    Tarif.register_subtype self

    enum :mode, { nights: 0, days: 1 }, prefix: true, default: :nights

    validates :mode, presence: true

    class Usage < ::Usage
      before_validation :normalize_details, :set_used_units

      def breakdown
        details_values = details&.values&.uniq&.compact || []
        return super if details_values.empty? || minimum?

        I18n.t(:overnight_stay, scope: 'invoice_items.breakdown', unit:, mode_factor: booking_dates.count,
                                details_factor: details_values.minmax.uniq.map { format_units(it) }.join(' … '),
                                billable_units: format_units(billable_units),
                                price_per_unit: format_price(price_per_unit))
      end

      def normalize_details
        return unless details.is_a?(Hash)

        keys = Array.wrap(booking_dates).map(&:iso8601)
        self.details = keys.index_with(0).merge(details.slice(*keys).transform_values { it.presence.try(:to_f) })
      end

      def set_used_units(force: false)
        return unless details&.values&.any?(&:present?) && (force || details_changed?)

        self.used_units = details.values.compact.sum
      end

      def booking_dates
        return unless tarif.present? && booking&.dates.present?

        dates = booking.dates.to_a
        dates.pop if tarif.mode_nights?
        dates
      end

      def preselect
        super
        self.details = booking_dates&.map(&:iso8601)&.index_with { prefill_units }
        normalize_details
        set_used_units(force: true)
      end
    end
  end
end
