# frozen_string_literal: true

class OccupancyCalendar
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Serialization

  attribute :organisation
  attribute :occupiables
  attribute :window_from, default: -> { Time.zone.today.beginning_of_day }
  attribute :window_to

  def initialize(attributes)
    super
    self.window_to ||= organisation.settings.booking_window.from_now
  end

  def occupancies
    @occupancies ||= Occupancy.occupancy_calendar.where(occupiable: occupiables)
                              .at(from: window_from, to: window_to)
                              .includes(booking: [:deadline])
  end
end
