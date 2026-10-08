# frozen_string_literal: true

class RenameOccupancyTypeToConflictType < ActiveRecord::Migration[8.1]
  def change
    rename_column :bookings, :occupancy_type, :occupancy_status
    rename_column :occupancies, :occupancy_type, :occupancy_status
  end
end
