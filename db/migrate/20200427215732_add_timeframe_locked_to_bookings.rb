class AddTimeframeLockedToBookings < ActiveRecord::Migration[6.0]
  def up
    add_column :bookings, :timeframe_locked, :boolean, default: false

    Booking.find_each do |booking|
      booking.update(timeframe_locked: true)
    end
  end

  def down
    remove_column :bookings, :timeframe_locked, :boolean, default: false
  end
end
