# frozen_string_literal: true

module Public
  class OccupancySerializer < ApplicationSerializer
    identifier :id
    association :occupiable, blueprint: Public::OccupiableSerializer
    association :occupancy_label, blueprint: Public::OccupancyLabelSerializer
    association :default_occupancy_label, blueprint: Public::OccupancyLabelSerializer

    fields :begins_at, :ends_at, :occupancy_status, :occupiable_id, :remarks, :nights, :color, :booking_id

    # field :color do |occupancy|

    # end

    field :ref do |occupancy|
      occupancy.booking&.ref
    end

    field :deadline do |occupancy|
      occupancy.booking&.deadline&.at
    end
  end
end
