class AddColorToOccupancies < ActiveRecord::Migration[7.0]
  def change
    add_column :occupancies, :color, :string, null: true
    add_column :bookings, :color, :string, null: true
  end
end
