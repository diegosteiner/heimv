class OccupancySerializer < ApplicationSerializer
  attributes *%i[begins_at ends_at]
end
