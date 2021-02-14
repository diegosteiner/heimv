# frozen_string_literal: true

module RefStrategies
  class BookingRef
    DEFAULT_TEMPLATE = '%<home_ref>s%<year>04d%<month>02d%<day>02d%<same_day_alpha>s'

    def self.ref_parts
      @ref_parts ||= {}
    end

    def self.ref_part(hash)
      ref_parts.merge!(hash)
    end

    ref_part home_ref: ->(booking) { booking.home.ref },
             year: ->(booking) { booking.occupancy.begins_at.year },
             month: ->(booking) { booking.occupancy.begins_at.month },
             day: ->(booking) { booking.occupancy.begins_at.day }

    ref_part same_month_count: (lambda do |booking|
      day = booking.occupancy.begins_at
      booking.home.occupancies.begins_at(after: day.beginning_of_month, before: day.end_of_month).count
    end)

    ref_part same_year_count: (lambda do |booking|
      day = booking.occupancy.begins_at
      booking.home.occupancies.begins_at(after: day.beginning_of_year, before: day.end_of_year).count
    end)

    ref_part same_day_alpha: (lambda do |booking|
      day = booking.occupancy.begins_at
      count = booking.home.occupancies.begins_at(after: day.beginning_of_day, before: day.end_of_day).count

      next '' if count < 2
      next count if count > 25

      # CHAR_START = 96
      (count + 95).chr
    end)

    def generate(booking, template_string = booking.organisation.ref_template)
      template_string ||= DEFAULT_TEMPLATE
      ref_parts = self.class.ref_parts.select { |key| template_string.include?(key.to_s) }
                      .transform_values { |callable| callable.call(booking) }
      format(template_string, ref_parts)
    end
  end
end
