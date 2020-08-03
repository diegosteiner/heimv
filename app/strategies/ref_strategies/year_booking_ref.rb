# frozen_string_literal: true

module RefStrategies
  class YearBookingRef < RefStrategy
    def generate(booking)
      format('%<year>04d-%<count>d',
             year: booking.occupancy.begins_at.year,
             count: 0)
    end
  end
end
