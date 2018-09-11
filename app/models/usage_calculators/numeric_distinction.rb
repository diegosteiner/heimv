module UsageCalculators
  class NumericDistinction < UsageCalculator
    DISTINCTION_REGEX = /\A([><=])?(\d*)\z/

    def select_usage(usage, distinction)
      distinction_match = self.class::DISTINCTION_REGEX.match(distinction) || return
      value = presumable_usage(usage)
      case distinction_match[1]
      when '<'
        return value < distinction_match[2].to_i
      when '>'
        return value > distinction_match[2].to_i
      else
        return distinction_match[2].blank? || value == distinction_match[2].to_i
      end
    end

    def calculate_usage(usage, _distinction)
      presumable_usage(usage) if usage.apply
    end

    def presumable_usage(usage); end
  end
end
