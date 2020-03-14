# == Schema Information
#
# Table name: tarif_selectors
#
#  id          :bigint           not null, primary key
#  distinction :string
#  type        :string
#  veto        :boolean          default("true")
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  tarif_id    :bigint
#
# Indexes
#
#  index_tarif_selectors_on_tarif_id  (tarif_id)
#
# Foreign Keys
#
#  fk_rails_...  (tarif_id => tarifs.id)
#

module TarifSelectors
  class BookingPurpose < TarifSelector
    def distinction_regex
      /\A(camp|event)\z/.freeze
    end

    def apply?(usage)
      distinction_match = distinction_regex.match(distinction)
      distinction_match[1] == usage.booking.purpose
    end
  end
end
