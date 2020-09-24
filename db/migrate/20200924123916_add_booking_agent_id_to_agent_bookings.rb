class AddBookingAgentIdToAgentBookings < ActiveRecord::Migration[6.0]
  def change
    add_reference :agent_bookings, :booking_agent, null: true, foreign_key: true
    remove_index :booking_agents, :code
    add_index :booking_agents, %i[code organisation_id], unique: true

    reversible do |direction|
      direction.up do 
        AgentBooking.find_each do |agent_booking| 
          agent_booking.assign_booking_agent
          agent_booking.save
        end
      end
    end

    change_column_null :agent_bookings, :booking_agent_id, false
  end
end
