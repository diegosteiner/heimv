# == Schema Information
#
# Table name: tarif_selectors
#
#  id         :bigint           not null, primary key
#  position   :integer
#  type       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  home_id    :bigint
#
# Indexes
#
#  index_tarif_selectors_on_home_id  (home_id)
#  index_tarif_selectors_on_type     (type)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#

require 'rails_helper'

RSpec.describe TarifSelector, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
