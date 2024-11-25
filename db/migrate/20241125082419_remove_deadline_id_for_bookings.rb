class RemoveDeadlineIdForBookings < ActiveRecord::Migration[7.2]
  def change
    reversible do |direction|
      direction.up do
        Deadline.where.not(id: Booking.pluck(:deadline_id)).delete_all
      end
    end

    remove_column :bookings, :deadline_id, :bigint, index: true
  end
end
