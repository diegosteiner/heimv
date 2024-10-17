class ChangeEditableNullOnBookings < ActiveRecord::Migration[7.2]
  def change
    change_column_null :bookings, :editable, true
    change_column_default :bookings, :editable, nil

    reversible do |direction|
      direction.up do
        Booking.update_all(editable: nil)
      end
    end
  end
end
