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
  class Metered < Tarif
    Tarif.register_subtype self

    def before_usage_save(usage)
      usage.used_units ||= usage.meter_reading_period&.used_units
    end
  end
end
