# frozen_string_literal: true

class MigrateFreeOccupancyType < ActiveRecord::Migration[8.0]
  def up
    Occupancy.where(occupancy_type: 0, linked: false).update_all(occupancy_type: 4) # rubocop:disable Rails/SkipsModelValidations
    Booking.where(occupancy_type: 0, concluded: false).update_all(occupancy_type: 4) # rubocop:disable Rails/SkipsModelValidations
    Occupancy.includes(:booking).joins(:booking).where(linked: true).find_each(&:update_from_booking)
  end
end
