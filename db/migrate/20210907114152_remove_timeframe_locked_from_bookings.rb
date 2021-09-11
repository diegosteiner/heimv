class RemoveTimeframeLockedFromBookings < ActiveRecord::Migration[6.1]
  def change
    remove_column :bookings, :timeframe_locked, :boolean, default: false
  end
end
