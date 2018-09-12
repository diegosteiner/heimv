module Public
  class OccupancySerializer < ApplicationSerializer
    belongs_to :home

    attributes :begins_at, :ends_at, :occupancy_type
  end
end
