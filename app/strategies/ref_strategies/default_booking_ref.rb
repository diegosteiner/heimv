module RefStrategies
  class DefaultBookingRef < RefStrategy
    def generate(booking)
      format('%s%04d%02d%02d',
              booking.home.ref[0...1],
              booking.occupancy.begins_at.year,
              booking.occupancy.begins_at.month,
              booking.occupancy.begins_at.day).upcase
    end

    def suffix(booking)
    end
  end
end
