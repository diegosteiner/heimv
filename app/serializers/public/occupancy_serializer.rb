# frozen_string_literal: true

module Public
  class OccupancySerializer < ApplicationSerializer
    identifier :id
    association :occupiable, blueprint: Public::OccupiableSerializer
    association :calendar_label, blueprint: Public::CalendarLabelSerializer
    association :default_calendar_label, blueprint: Public::CalendarLabelSerializer

    fields :begins_at, :ends_at, :conflict_type, :occupiable_id, :remarks, :nights, :color, :booking_id

    # field :color do |occupancy|

    # end

    field :ref do |occupancy|
      occupancy.booking&.ref
    end

    field :deadline do |occupancy|
      occupancy.booking&.deadline&.at
    end
  end
end
