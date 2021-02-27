class AddBookingToOccupancies < ActiveRecord::Migration[6.1]
  def down
    add_column :bookings, :occupancy_id, :uuid, foreign_key: true

    Occupancy.all.pluck(:id, :booking_id).each do |(occupancy_id, booking_id)|
      next unless booking_id.present?

      Booking.find(booking_id).update_columns(occupancy_id: occupancy_id)
    end

    remove_column :occupancies, :booking_id
    add_column :occupancies, :booking_type, :string
  end

  def up
    add_column :occupancies, :booking_id, :uuid, foreign_key: true

    Booking.all.pluck(:id, :occupancy_id).each do |(booking_id, occupancy_id)|
      next unless occupancy_id.present?

      Occupancy.find(occupancy_id).update_columns(booking_id: booking_id)
    end

    remove_column :bookings, :occupancy_id
    remove_column :occupancies, :booking_type
  end
end
