module UsageCalculators
  class BookingPurpose < UsageCalculator
    DISTINCTION_REGEX = %r{\A(camp|event)\z}

    def calculate_apply(usage, distinction)
      distinction_match = DISTINCTION_REGEX.match(distinction)
      usage.apply ||= distinction_match[1] == usage.booking.purpose
    end
  end
end
