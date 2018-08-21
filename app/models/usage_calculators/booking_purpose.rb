module UsageCalculators
  class BookingPurpose < UsageCalculator
    DISTINCTION_REGEX = /\A(camp|event)\z/

    def select_usage(usage, distinction)
      distinction_match = DISTINCTION_REGEX.match(distinction)
      usage.apply ||= distinction_match[1] == usage.booking.purpose
    end
  end
end
