class AddDeadlineIdToBookings < ActiveRecord::Migration[6.0]
  def down
    remove_reference :bookings, :deadline, null: true
  end

  def up
    add_reference :bookings, :deadline, null: true

    Booking.find_each do |booking|
      booking.update_columns(deadline_id: booking.deadlines.next.pluck(:id))
    end
  end
end
