module TarifSelectors
  class BookingOvernightStays < NumericDistinction
    def presumable_usage(usage)
      usage.booking.overnight_stays
    end
  end
end
