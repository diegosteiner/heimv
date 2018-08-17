module UsageCalculators
  class BookingPurpose < UsageCalculator
    DISTINCTION_PROCS = {
      camp: (lambda do |usage|
        return unless usage.booking.purpose
        usage.used_units = usage.booking.approximate_headcount
        usage.apply = true
      end)
    }.freeze.with_indifferent_access
  end
end
