module TarifSelectors
  class NumericDistinction < TarifSelector
    DISTINCTION_REGEX = /\A([><=])?(\d*)\z/

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
