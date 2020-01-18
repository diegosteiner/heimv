# frozen_string_literal: true

module Manage
  class BookingFilterParams < ApplicationParams
    def self.permitted_keys
      %i[tenant ref] +
        [booking_states: [], homes: [], occupancy_params: OccupancyFilterParams.permitted_keys]
    end
  end
end
