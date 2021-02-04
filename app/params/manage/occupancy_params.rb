# frozen_string_literal: true

module Manage
  class OccupancyParams < Public::OccupancyParams
    def self.permitted_keys
      super + %i[occupancy_type remarks]
    end
  end
end
