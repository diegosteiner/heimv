# frozen_string_literal: true

module RefStrategies
  class DefaultBookingRef < RefStrategy
    CHAR_START = 96

    def generate(booking)
      format('%<home>s%<year>04d%<month>02d%<day>02d%<suffix>s',
             home: booking.home.ref[0...1].upcase,
             year: booking.occupancy.begins_at.year,
             month: booking.occupancy.begins_at.month,
             day: booking.occupancy.begins_at.day,
             suffix: suffix(booking))
    end

    def suffix(booking)
      day = booking.occupancy.begins_at
      on_same_day_count = booking.home.occupancies.where.not(id: booking.id)
                                 .begins_at(after: day.beginning_of_day, before: day.end_of_day)
                                 .count

      (on_same_day_count + CHAR_START).chr unless on_same_day_count < 1 || on_same_day_count > 25
    end
  end
end
