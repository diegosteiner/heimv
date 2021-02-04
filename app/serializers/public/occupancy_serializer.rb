# frozen_string_literal: true

module Public
  class OccupancySerializer < ApplicationSerializer
    fields :begins_at, :ends_at, :occupancy_type, :home_id, :remarks

    association :booking,     blueprint: Public::OccupancySerializer
  end
end
