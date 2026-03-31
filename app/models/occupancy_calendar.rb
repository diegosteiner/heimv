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
                           .where(free_without_booking_arel)
                           .includes(occupiable: [:organisation], booking: %i[deadline organisation])
    return occupancies unless public_visibility

    occupancies.where(occupancy_type: organisation.settings.public_occupancy_visibility)
  end

  private

  def free_without_booking_arel
    Occupancy.arel_table[:occupancy_type].not_eq(Occupancy.occupancy_types[:free])
             .or(Occupancy.arel_table[:booking_id].eq(nil))
  end
end
