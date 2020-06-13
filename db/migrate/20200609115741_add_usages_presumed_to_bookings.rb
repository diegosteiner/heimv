class AddUsagesPresumedToBookings < ActiveRecord::Migration[6.0]
  def change
    add_column :bookings, :usages_presumed, :boolean, default: false
  end
end
