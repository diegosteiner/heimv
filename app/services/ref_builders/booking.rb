# frozen_string_literal: true

module RefBuilders
  class Booking < RefBuilder
    DEFAULT_TEMPLATE = '%<home_ref>s%<year>04d%<month>02d%<day>02d%<same_ref_alpha>s'

    def initialize(booking)
      super(booking.organisation)
      @booking = booking
    end

    ref_part home_ref: proc { @booking.home.ref },
             year: proc { @booking.begins_at.year },
             short_year: proc { @booking.begins_at.year - 2000 },
             month: proc { @booking.begins_at.month },
             day: proc { @booking.begins_at.day },
             sequence_number: proc { @booking.sequence_number },
             sequence_year: proc { @booking.sequence_year },
             short_sequence_year: proc { @booking.sequence_year - 2000 }

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

    # ref_part same_ref_alpha: (proc do
    #   day = @booking.begins_at
    #   count = @booking.organisation.bookings.begins_at(after: day.beginning_of_day, before: day.end_of_day).count

    #   next '' if count < 2
    #   next count if count > 25

    #   # CHAR_START = 96
    #   (count + 95).chr
    # end)
    #

    def generate(template_string = @organisation.booking_ref_template)
      same_ref_alpha = ''
      retries = 0
      loop do
        ref = generate_lazy(template_string, same_ref_alpha:)

        return ref unless @organisation.bookings.exists?(ref:)
        return nil if retries > 25

        same_ref_alpha = ((retries += 1) + 95).chr
      end
    end
  end
end
