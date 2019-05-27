# frozen_string_literal: true

module Manage
  class BookingFilterParams < ApplicationParams
    nested occupancy_params: OccupancyFilterParams

    def self.permitted_keys
      %i[tenant ref] + [booking_states: [], homes: []]
    end
  end
end
