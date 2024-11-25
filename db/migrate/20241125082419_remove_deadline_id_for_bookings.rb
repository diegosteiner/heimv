class RemoveDeadlineIdForBookings < ActiveRecord::Migration[7.2]
  def change
    reversible do |direction|
      direction.up do
        # remove all non referenced deadlines
        Deadline.where.not(id: Booking.plick(:deadline_id)).delete_all
      end
    end

    remove_column :bookings, :deadline_id, :bigint, index: true
  end
end
