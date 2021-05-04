class AddPositionToBookingPurpose < ActiveRecord::Migration[6.1]
  def change
    add_column :booking_purposes, :position, :integer
    add_index :booking_purposes, :position

    reversible do |direction|
      direction.up do 
        BookingPurpose.find_each do |booking_purpose|
          booking_purpose.update!(position: booking_purpose.created_at.to_i)
        end
      end
    end
  end
end
