module TarifSelectors
  class BookingNights < NumericDistinction
    def presumable_usage(usage)
      usage.booking.occupancy.nights
    end
  end
end
