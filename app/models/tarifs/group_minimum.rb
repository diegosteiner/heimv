# frozen_string_literal: true

# == Schema Information
#
# Table name: tarifs
#
#  id                                :bigint           not null, primary key
#  accountancy_account               :string
#  associated_types                  :integer          default(0), not null
#  discarded_at                      :datetime
#  label_i18n                        :jsonb
#  minimum_price_per_night           :decimal(, )
#  minimum_price_total               :decimal(, )
#  minimum_usage_per_night           :decimal(, )
#  minimum_usage_total               :decimal(, )
#  ordinal                           :integer
#  pin                               :boolean          default(TRUE)
#  prefill_usage_method              :string
#  price_per_unit                    :decimal(, )
#  tarif_group                       :string
#  type                              :string
#  unit_i18n                         :jsonb
#  valid_from                        :datetime
#  valid_until                       :datetime
#  vat                               :decimal(, )
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  organisation_id                   :bigint           not null
#  prefill_usage_booking_question_id :bigint
#
# Indexes
#
#  index_tarifs_on_discarded_at                       (discarded_at)
#  index_tarifs_on_organisation_id                    (organisation_id)
#  index_tarifs_on_prefill_usage_booking_question_id  (prefill_usage_booking_question_id)
#  index_tarifs_on_type                               (type)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#  fk_rails_...  (prefill_usage_booking_question_id => booking_questions.id)
#
module Tarifs
  class GroupMinimum < Tarif
    Tarif.register_subtype self

    def usages_in_group(usage)
      usage.booking.usages.joins(:tarif)
           .where(tarifs: { tarif_group: usage.tarif.tarif_group })
           .where.not(id: usage.id)
    end

    def group_price(usage)
      usages_in_group(usage).sum(&:price)
    end

    def group_used_units(usage)
      usages_in_group(usage).sum { _1.used_units || 0 }
    end

    def minimum_prices_with_difference(usage) # rubocop:disable Metrics/AbcSize
      nights = usage&.booking&.nights || 0
      price_per_unit = usage&.price_per_unit || 0
      minimum_prices = minimum_prices(usage)
      {
        minimum_usage_per_night: (((minimum_usage_per_night || 0) * nights) - group_used_units(usage)) * price_per_unit,
        minimum_usage_total: ((minimum_usage_total || 0) - group_used_units(usage)) * price_per_unit,
        minimum_price_per_night: minimum_prices[:minimum_price_per_night] - group_price(usage),
        minimum_price_total: minimum_prices[:minimum_price_total] - group_price(usage)
      }
    end

    def minimum_price(usage)
      if usage.price_per_unit&.negative?
        minimum_prices_with_difference(usage).filter { _2.negative? }.min_by { _2 }
      else
        minimum_prices_with_difference(usage).filter { _2.positive? }.max_by { _2 }
      end
    end

    def apply_usage_to_invoice?(usage, _invoice)
      super && usage.price.positive?
    end

    def presumed_units(usage)
      0
    end
  end
end
