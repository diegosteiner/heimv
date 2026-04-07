# frozen_string_literal: true

OccupancyCalendar = Data.define(:organisation, :occupiables, :public_visibility, :window_from, :window_to) do
  extend ActiveModel::Naming
  extend ActiveModel::Translation

  def initialize(organisation:, occupiables:, public_visibility: true, window_from: nil, window_to: nil)
    window_from ||= public_visibility ? Time.zone.today.beginning_of_day : 1.year.ago.beginning_of_day
    window_to ||= organisation.settings.booking_window.from_now

    super({ organisation:, occupiables:, public_visibility:, window_from:, window_to: })
  end

  def occupancies
    occupancies = Occupancy.where(occupiable: occupiables).at(from: window_from, to: window_to)
                           .where.not(occupancy_type: :free)
                           .includes(occupiable: [:organisation], booking: %i[deadline organisation])
    return occupancies unless public_visibility

    occupancies.where(occupancy_type: organisation.settings.public_occupancy_visibility)
  end
end
