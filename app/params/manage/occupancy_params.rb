# frozen_string_literal: true

module Manage
  class OccupancyParams < ApplicationParams
    def self.permitted_keys
      %i[begins_at ends_at occupancy_status remarks color linked occupiable_id ignore_conflicting]
    end
  end
end
