# frozen_string_literal: true

module Manage
  class BookingFilterParams < ApplicationParams
    def self.permitted_keys
      %i[tenant ref] + [booking_states: [], homes: [], occupancy_params: OccupancyFilterParams.permitted_keys]
    end

    def self.sanitize(params)
      params[:occupancy_params] = OccupancyFilterParams.sanitize(params[:occupancy_params])
      params
    end
  end
end
