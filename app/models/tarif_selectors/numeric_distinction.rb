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
  class NumericDistinction < TarifSelector
    DISTINCTION_REGEX = /\A([><=])?(\d*)\z/.freeze

    def apply?(usage, presumable_usage = presumable_usage(usage))
      distinction_match = self.class::DISTINCTION_REGEX.match(distinction) || return
      case distinction_match[1]
      when '<'
        presumable_usage < distinction_match[2].to_i
      when '>'
        presumable_usage > distinction_match[2].to_i
      else
        distinction_match[2].blank? || presumable_usage == distinction_match[2].to_i
      end
    end

    def presumable_usage(usage); end
  end
end
