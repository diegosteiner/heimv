# frozen_string_literal: true

module Public
  class OccupancyCalendarSerializer < ApplicationSerializer
    DEFAULT_INCLUDES = 'occupancies.booking,occupancies.booking.organisation'

    association :occupiables, blueprint: Public::OccupiableSerializer
    association :occupancies, blueprint: Public::OccupancySerializer

    fields :window_from, :window_to
  end
end
