# frozen_string_literal: true

module Public
  class OccupancyCalendarSerializer < ApplicationSerializer
    DEFAULT_INCLUDES = %w[occupancies.booking occupancies.booking.organisation occupancies.occupancy_label
                          occupancies.default_occupancy_label].join(',')

    association :occupiables, blueprint: Public::OccupiableSerializer
    association :occupancies, blueprint: Public::OccupancySerializer

    fields :window_from, :window_to
  end
end
