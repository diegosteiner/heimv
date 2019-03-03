# == Schema Information
#
# Table name: tarif_selectors
#
#  id         :bigint(8)        not null, primary key
#  home_id    :bigint(8)
#  type       :string
#  position   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe TarifSelector, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
