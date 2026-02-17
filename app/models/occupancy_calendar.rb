# frozen_string_literal: true

class OccupancyCalendar
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Serialization

  attribute :organisation
  attribute :occupiables
  attribute :seasons

  def occupancies
    @occupancies ||= Occupancy.occupancy_calendar.where(occupiable: occupiables, season: seasons)
                              .includes(occupiable: [:organisation], booking: %i[deadline organisation])
  end

  def seasons
    @seasons ||= organisation.seasons.future.where(status: :open)
  end
end
