# frozen_string_literal: true

module Public
  class OccupancyParams < ApplicationParams
    def self.permitted_keys
      %i[begins_at ends_at]
    end
  end
end
