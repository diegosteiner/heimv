# == Schema Information
#
# Table name: tarifs
#
#  id                       :bigint(8)        not null, primary key
#  type                     :string
#  label                    :string
#  transient                :boolean          default(FALSE)
#  booking_id               :uuid
#  home_id                  :bigint(8)
#  booking_copy_template_id :bigint(8)
#  unit                     :string
#  price_per_unit           :decimal(, )
#  valid_from               :datetime
#  valid_until              :datetime
#  position                 :integer
#  tarif_group              :string
#  invoice_type             :string
#  prefill_usage_method     :string
#  meter                    :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

module Tarifs
  class Amount < ::Tarif
  end
end
