class Occupancy
  class Filter < ApplicationFilter
    attribute :begins_at_after, :datetime
    attribute :begins_at_before, :datetime
    attribute :ends_at_after, :datetime
    attribute :ends_at_before, :datetime

    filter :begins_at_ends_at do |occupancies|
      occupancies.begins_at(after: begins_at_after, before: begins_at_before)
                 .ends_at(after: ends_at_after, before: ends_at_before)
    end
  end
end
