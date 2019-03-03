# == Schema Information
#
# Table name: tarif_tarif_selectors
#
#  id                :bigint(8)        not null, primary key
#  tarif_id          :bigint(8)
#  tarif_selector_id :bigint(8)
#  veto              :boolean          default(TRUE)
#  distinction       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'rails_helper'

RSpec.describe TarifTarifSelector, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
