# == Schema Information
#
# Table name: tarif_selectors
#
#  id         :bigint           not null, primary key
#  home_id    :bigint
#  type       :string
#  position   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module TarifSelectors
  class AlwaysApply < TarifSelector
    def apply?(_usage, _distinction)
      true
    end
  end
end
