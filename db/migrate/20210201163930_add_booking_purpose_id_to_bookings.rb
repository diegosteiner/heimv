class AddBookingPurposeIdToBookings < ActiveRecord::Migration[6.1]
  def change
    add_reference :bookings, :purpose, null: true, foreign_key: true

    reversible do |direction|
      direction.up do 
        Booking.find_each do |booking|
          purpose = booking.organisation.booking_purposes.find_by(key: booking.purpose_key)
          booking.update(purpose: purpose) if purpose
        end
      end
    end

    remove_column :bookings, :purpose_key, :string
  end
end
