class AddHomeIdToBookings < ActiveRecord::Migration[7.0]
  def change
    add_column :occupancies, :linked, :boolean, default: true
    add_column :bookings, :home_id, :integer, null: true, index: true, foreign_key: { to_table: :occupiables }

    reversible do |direction|
      direction.up do 
        Booking.find_each do |booking| 
          booking.update!(home_id: booking.occupiable_ids.first) 
        end
      end
    end

    change_column_null :bookings, :home_id, false
  end
end
