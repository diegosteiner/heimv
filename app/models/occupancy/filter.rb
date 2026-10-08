# frozen_string_literal: true

class Occupancy
  class Filter < ApplicationFilter
    attribute :begins_at_after, :datetime
    attribute :begins_at_before, :datetime
    attribute :ends_at_after, :datetime
    attribute :ends_at_before, :datetime
    attribute :occupancy_status, default: -> { [] }

    filter :begins_at_ends_at do |occupancies|
      occupancies.begins_at(after: begins_at_after, before: begins_at_before)
                 .ends_at(after: ends_at_after, before: ends_at_before)
    end

    filter :occupancy_status do |occupancies|
      occupancy_statuses = Array.wrap(occupancy_status).compact_blank
      occupancies.where(occupancy_status: occupancy_statuses) if occupancy_statuses.present?
    end
  end
end
