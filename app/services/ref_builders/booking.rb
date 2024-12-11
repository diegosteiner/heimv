# frozen_string_literal: true

module RefBuilders
  class Booking < RefBuilder
    DEFAULT_TEMPLATE = '%<home_ref>s%<year>04d%<month>02d%<day>02d%<same_day_alpha>s'

    def initialize(booking)
      super(booking.organisation)
      @booking = booking
    end

    ref_part home_ref: proc { @booking.home.ref },
             year: proc { @booking.begins_at.year },
             month: proc { @booking.begins_at.month },
             day: proc { @booking.begins_at.day }

    ref_part occupiable_refs: (proc do
      @booking.occupancies.map(&:occupiable).sort_by(&:ordinal).map(&:ref).join
    end)

    # ref_part same_month_count: (proc do |@booking|
    #   day = @booking.begins_at
    #   @booking.organisation.@bookings.begins_at(after: day.beginning_of_month, before: day.end_of_month).count
    # end)

    # ref_part same_year_count: (proc do |@booking|
    #   day = @booking.begins_at
    #   @booking.organisation.@bookings.begins_at(after: day.beginning_of_year, before: day.end_of_year).count
    # end)

    ref_part same_day_alpha: (proc do
      day = @booking.begins_at
      count = @booking.organisation.bookings.begins_at(after: day.beginning_of_day, before: day.end_of_day).count

      next '' if count < 2
      next count if count > 25

      # CHAR_START = 96
      (count + 95).chr
    end)

    def generate(template_string = @organisation.booking_ref_template)
      generate_lazy(template_string)
    end
  end
end
