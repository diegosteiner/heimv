# frozen_string_literal: true

module RefStrategies
  class YearBookingRef < RefStrategy
    def generate(booking)
      year = booking.occupancy.begins_at.year
      # counter = MeterReadingPeriod.find_or_create_by(home: booking.home, meter_name: "refs_#{year}")

      format('%<year>04d-%<count>d',
             year: year,
             count: 0)
    end
  end
end
