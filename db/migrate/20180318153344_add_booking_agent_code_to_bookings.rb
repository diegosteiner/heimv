class AddBookingAgentCodeToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :booking_agent_code, :string, null: true
    add_column :bookings, :booking_agent_ref, :string, null: true
  end
end
