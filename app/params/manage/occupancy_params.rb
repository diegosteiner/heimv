# frozen_string_literal: true

module Manage
  class OccupancyParams < ApplicationParams
    def self.permitted_keys
      %i[begins_at ends_at occupancy_type remarks color]
    end
  end
end
