# frozen_string_literal: true

module Public
  class OccupancySerializer < ApplicationSerializer
    association :occupiable, blueprint: Public::OccupiableSerializer

    fields :begins_at, :ends_at, :occupancy_type, :occupiable_id, :remarks, :id, :nights, :color

    field :ref do |occupancy|
      occupancy.booking&.ref
    end

    field :deadline do |occupancy|
      occupancy.booking&.deadline&.at
    end
  end
end
