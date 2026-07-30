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
  class OvernightStay < ::Tarif
    Tarif.register_subtype self

    enum :mode, { nights: 0, days: 1 }, prefix: true, default: :nights

    validates :mode, presence: true

    class Usage < ::Usage
      before_validation :normalize_details, :set_used_units

      def breakdown
        return super if minimum_price?

        details_values = details&.values&.compact_blank&.uniq
        return "#{used_units} #{unit} (#{booking_dates.count} × #{details_values.first})" if details_values.count.one?

        "#{used_units} #{unit} (#{booking_dates.count} × #{details_values.min} … #{details_values.min})"
      end

      def normalize_details
        self.details = details&.slice(*booking_dates&.map(&:iso8601))&.transform_values { it.presence&.to_f } || {}
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
