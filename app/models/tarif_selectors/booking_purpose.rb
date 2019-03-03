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

module TarifSelectors
  class BookingPurpose < TarifSelector
    DISTINCTION_REGEX = /\A(camp|event)\z/.freeze

    def apply?(usage, distinction)
      distinction_match = DISTINCTION_REGEX.match(distinction)
      distinction_match[1] == usage.booking.purpose
    end
  end
end
