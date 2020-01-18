# == Schema Information
#
# Table name: tarif_tarif_selectors
#
#  id                  :bigint           not null, primary key
#  distinction         :string
#  tarif_selector_type :string
#  veto                :boolean          default(TRUE)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  tarif_id            :bigint
#  tarif_selector_id   :bigint
#
# Indexes
#
#  index_tarif_tarif_selectors_on_tarif_id           (tarif_id)
#  index_tarif_tarif_selectors_on_tarif_selector_id  (tarif_selector_id)
#
# Foreign Keys
#
#  fk_rails_...  (tarif_id => tarifs.id)
#  fk_rails_...  (tarif_selector_id => tarif_selectors.id)
#

require 'rails_helper'

RSpec.describe TarifTarifSelector, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
