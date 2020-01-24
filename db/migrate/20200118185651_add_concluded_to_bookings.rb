class AddConcludedToBookings < ActiveRecord::Migration[6.0]
  def change
    add_column :bookings, :concluded, :boolean, default: false
  end
end
