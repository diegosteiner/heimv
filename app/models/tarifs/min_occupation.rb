# frozen_string_literal: true

# == Schema Information
#
# Table name: tarifs
#
#  id                      :bigint           not null, primary key
#  accountancy_account     :string
#  associated_types        :integer          default(0), not null
#  discarded_at            :datetime
#  label_i18n              :jsonb
#  minimum_usage_per_night :decimal(, )
#  minimum_usage_total     :decimal(, )
#  ordinal                 :integer
#  pin                     :boolean          default(TRUE)
#  prefill_usage_method    :string
#  price_per_unit          :decimal(, )
#  tarif_group             :string
#  type                    :string
#  unit_i18n               :jsonb
#  valid_from              :datetime
#  valid_until             :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  organisation_id         :bigint           not null
#
# Indexes
#
#  index_tarifs_on_discarded_at     (discarded_at)
#  index_tarifs_on_organisation_id  (organisation_id)
#  index_tarifs_on_type             (type)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

module Tarifs
  class MinOccupation < Tarif
    Tarif.register_subtype self

    def before_usage_validation(usage)
      usage.used_units = calculate_usage_delta(usage)
    end

    protected

    def actual_overnight_stays(booking)
      booking.usages.filter_map { |usage| usage.tarif.is_a?(Tarifs::OvernightStay) && usage.used_units }.compact.sum
    end

    def calculate_usage_delta(usage)
      booking = usage.booking
      minimum_usage = (minimum_usage_per_night || 0) * (booking.nights || 0)
      delta = minimum_usage - actual_overnight_stays(booking)
      delta.positive? ? delta : 0
    end
  end
end
