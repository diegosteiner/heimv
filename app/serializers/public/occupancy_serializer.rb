# frozen_string_literal: true

module Public
  class OccupancySerializer < ApplicationSerializer
    association :home,        blueprint: Public::HomeSerializer

    fields :begins_at, :ends_at, :occupancy_type, :home_id, :remarks, :id, :nights, :color

    field :ref do |occupancy|
      occupancy.booking&.ref
    end

    field :deadline do |occupancy|
      occupancy.booking&.deadline&.at
    end
  end
end
