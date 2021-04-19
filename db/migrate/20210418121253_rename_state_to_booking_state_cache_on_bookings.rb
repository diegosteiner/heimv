class RenameStateToBookingStateCacheOnBookings < ActiveRecord::Migration[6.1]
  def change
    rename_column :bookings, :state, :booking_state_cache
  end
end
