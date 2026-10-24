# frozen_string_literal: true

class Occupancy
  class Filter < ApplicationFilter
    attribute :begins_at_after, :datetime
    attribute :begins_at_before, :datetime
    attribute :ends_at_after, :datetime
    attribute :ends_at_before, :datetime
    attribute :conflict_type, default: -> { [] }
    attribute :calendar_labels, default: -> { [] }

    filter :begins_at_ends_at do |occupancies|
      occupancies.begins_at(after: begins_at_after, before: begins_at_before)
                 .ends_at(after: ends_at_after, before: ends_at_before)
    end

    filter :conflict_type do |occupancies|
      conflict_types = Array.wrap(conflict_type).compact_blank
      occupancies.where(conflict_type: conflict_types) if conflict_types.present?
    end

    filter :calendar_labels do |occupancies|
      calendar_labels = Array.wrap(self.calendar_labels).compact_blank
      occupancies.where(calendar_label: calendar_labels) if calendar_labels.present?
    end
  end
end
