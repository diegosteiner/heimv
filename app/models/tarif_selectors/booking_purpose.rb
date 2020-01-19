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

module TarifSelectors
  class BookingPurpose < TarifSelector
    DISTINCTION_REGEX = /\A(camp|event)\z/.freeze

    def apply?(usage)
      distinction_match = DISTINCTION_REGEX.match(distinction)
      distinction_match[1] == usage.booking.purpose
    end
  end
end
