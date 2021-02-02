class AddBookingPurposeIdToBookings < ActiveRecord::Migration[6.1]
  def change
    add_column :bookings, :purpose_id, :integer, null: true, foreign_key: true

    reversible do |direction|
      direction.up do 
        Booking.find_each do |booking|
          purpose_key = booking.purpose_key
          next unless purpose_key.present?

          booking.update!(purpose: booking.organisation.booking_purposes.find_by(key: purpose_key))
        end
      end
    end

    # remove_column :bookings, :purpose_key, :string
  end
end
