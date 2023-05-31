class AddSkipConflictingToOccupancies < ActiveRecord::Migration[7.0]
  def change
    add_column :occupancies, :ignore_conflicting, :boolean, default: false, null: false
    add_column :bookings, :ignore_conflicting, :boolean, default: false, null: false
  end
end
