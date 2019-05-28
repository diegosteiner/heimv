# frozen_string_literal: true

module Manage
  class OccupancyFilterParams < ApplicationParams
    def self.permitted_keys
      %i[begins_at_before begins_at_after ends_at_before ends_at_after]
    end
  end
end
