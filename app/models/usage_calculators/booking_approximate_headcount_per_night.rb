module UsageCalculators
  class BookingApproximateHeadcountPerNight < NumericDistinction
    def presumable_usage(usage)
      usage.booking.approximate_headcount
    end

    def calculate_apply(usage, distinction)
      return unless usage.apply
      usage.used_units ||= usage.booking.nights + 1
    end
  end
end
