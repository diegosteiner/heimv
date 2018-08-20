module UsageCalculators
  class NumericDistinction < UsageCalculator
    DISTINCTION_REGEX = %r{\A([><=])?(\d*)\z}

    def calculate_apply(usage, distinction)
      distinction_match = self.class::DISTINCTION_REGEX.match(distinction)
      value = presumable_usage(usage)
      usage.apply ||= case distinction_match[1]
                    when '<'
                      value < distinction_match[2].to_i
                    when '>'
                      value > distinction_match[2].to_i
                    else
                      distinction_match[2].blank? || value == distinction_match[2].to_i
                    end
    end

    def calculate_used_units(usage, distinction)
      usage.used_units = presumable_usage(usage) if usage.apply
    end

    def presumable_usage(usage)
    end
  end
end
