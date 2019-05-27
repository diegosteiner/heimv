# frozen_string_literal: true

module Manage
  class OccupancyFilterParams < ApplicationParams
    multi_param begins_at_after: DateTime, begins_at_before: DateTime, ends_at_after: DateTime, ends_at_before: DateTime

    def self.permitted_keys
      %i[begins_at_before begins_at_after ends_at_before ends_at_after]
    end

  end
end
