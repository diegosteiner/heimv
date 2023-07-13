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
#  vat                     :decimal(, )
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
  class Amount < ::Tarif
    Tarif.register_subtype self
  end
end
