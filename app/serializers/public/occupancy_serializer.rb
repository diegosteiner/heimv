# frozen_string_literal: true

module Public
  class OccupancySerializer < ApplicationSerializer
    fields :begins_at, :ends_at, :occupancy_type, :home_id

    field :ref do |occupancy|
      occupancy.booking&.ref
    end

    field :deadline do |occupancy|
      occupancy.booking&.deadline&.at
    end

    field :links do
      # { handle: occupancy_at_path(t: object.begins_at.to_s) }
    end
  end
end
