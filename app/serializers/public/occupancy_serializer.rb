# frozen_string_literal: true

module Public
  class OccupancySerializer < ApplicationSerializer
    # association :booking, blueprint: Public::Booking  field :ref do |occupancy|

    fields :begins_at, :ends_at, :occupancy_type, :home_id, :remarks

    field :ref do |occupancy|
      occupancy.booking&.ref
    end

    field :deadline do |occupancy|
      occupancy.booking&.deadline&.at
    end
  end
end
