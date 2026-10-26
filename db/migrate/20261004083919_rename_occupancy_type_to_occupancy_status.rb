# frozen_string_literal: true

class RenameOccupancyTypeToOccupancyStatus < ActiveRecord::Migration[8.1]
  def change
    rename_column :bookings, :occupancy_type, :conflict_type
    rename_column :occupancies, :occupancy_type, :conflict_type
  end
end
