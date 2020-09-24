class ChangeBookingAgentIdNullOnAgentBookings < ActiveRecord::Migration[6.0]
  def change
    change_column_null :agent_bookings, :booking_agent_id, false
  end
end
