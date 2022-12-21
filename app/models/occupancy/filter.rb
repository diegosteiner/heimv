# frozen_string_literal: true

class Occupancy
  class Filter < ApplicationFilter
    attribute :begins_at_after, :datetime
    attribute :begins_at_before, :datetime
    attribute :ends_at_after, :datetime
    attribute :ends_at_before, :datetime
    attribute :occupancy_type, default: -> { [] }

    filter :begins_at_ends_at do |occupancies|
      occupancies.begins_at(after: begins_at_after, before: begins_at_before)
                 .ends_at(after: ends_at_after, before: ends_at_before)
    end

    filter :occupancy_type do |occupancies|
      occupancy_types = Array.wrap(occupancy_type).compact_blank
      occupancies.where(occupancy_type: occupancy_types) if occupancy_types.present?
    end
  end
end
