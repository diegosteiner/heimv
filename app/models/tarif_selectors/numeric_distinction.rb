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
  class NumericDistinction < TarifSelector
    DISTINCTION_REGEX = /\A([><=])?(\d*)\z/.freeze

    def apply?(usage, distinction, presumable_usage = presumable_usage(usage))
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
