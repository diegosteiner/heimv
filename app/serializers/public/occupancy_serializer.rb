module Public
  class OccupancySerializer < ApplicationSerializer
    attributes :begins_at, :ends_at, :occupancy_type, :home_id

    attribute :ref do
      object.booking&.ref
    end

    attribute :deadline do
      object.booking&.deadline&.at
    end

    attribute :links do
      # { handle: occupancy_at_path(t: object.begins_at.to_s) }
    end
  end
end
