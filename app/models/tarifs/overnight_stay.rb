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
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  organisation_id                   :bigint           not null
#  prefill_usage_booking_question_id :bigint
#  vat_category_id                   :bigint
#
# Indexes
#
#  index_tarifs_on_discarded_at                       (discarded_at)
#  index_tarifs_on_organisation_id                    (organisation_id)
#  index_tarifs_on_prefill_usage_booking_question_id  (prefill_usage_booking_question_id)
#  index_tarifs_on_type                               (type)
#  index_tarifs_on_vat_category_id                    (vat_category_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#  fk_rails_...  (prefill_usage_booking_question_id => booking_questions.id)
#  fk_rails_...  (vat_category_id => vat_categories.id)
#

module Tarifs
  class OvernightStay < ::Tarif
    Tarif.register_subtype self

    def before_usage_validation(usage)
      usage.instance_exec do
        self.details = details&.slice(*booking.dates.map(&:iso8601))&.transform_values { _1.presence&.to_f } || {}
        self.used_units = details.values.compact.sum if used_units.blank?
      end
    end
  end
end
