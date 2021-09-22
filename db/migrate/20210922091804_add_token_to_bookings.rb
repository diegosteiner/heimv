class AddTokenToBookings < ActiveRecord::Migration[6.1]
  def change
    add_column :bookings, :token, :string, null: true
    add_index :bookings, :token, unique: true
    add_column :agent_bookings, :token, :string, null: true
    add_index :agent_bookings, :token, unique: true

    reversible do |direction|
      direction.up do 
        Booking.find_each { |booking| booking.regenerate_token }
        AgentBooking.find_each { |agent_booking| agent_booking.regenerate_token }
      end
    end
  end
end
