class Occupancy
  class Filter < ApplicationFilter
    attribute :begins_at_after, :datetime
    attribute :begins_at_before, :datetime
    attribute :ends_at_after, :datetime
    attribute :ends_at_before, :datetime

    filter do |occupancy, f|
      Occupancy.where.not(booking: nil)
                .begins_at(after: f.begins_at_after, before: f.begins_at_before)
                .ends_at(after: f.ends_at_after, before: f.ends_at_before)
    end
  end
end
