# frozen_string_literal: true

# == Schema Information
#
# Table name: tarifs
#
#  id                   :bigint           not null, primary key
#  accountancy_account  :string
#  invoice_types        :integer          default(0), not null
#  label_i18n           :jsonb
#  ordinal              :integer
#  pin                  :boolean          default(TRUE)
#  prefill_usage_method :string
#  price_per_unit       :decimal(, )
#  tarif_group          :string
#  tenant_visible       :boolean          default(TRUE)
#  type                 :string
#  unit_i18n            :jsonb
#  valid_from           :datetime
#  valid_until          :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  booking_id           :uuid
#  home_id              :bigint
#
# Indexes
#
#  index_tarifs_on_booking_id  (booking_id)
#  index_tarifs_on_home_id     (home_id)
#  index_tarifs_on_type        (type)
#

module Tarifs
  class MinOccupation < Tarif
    Tarif.register_subtype self

    belongs_to :depends_on_tarif, class_name: 'Tarif', optional: true

    def price(usage)
      [0, super - price_cleared(usage)].max
    end

    def price_cleared(usage)
      usage.booking.usages.of_tarif(depends_on_tarif).take&.price || 0
    end
  end
end
