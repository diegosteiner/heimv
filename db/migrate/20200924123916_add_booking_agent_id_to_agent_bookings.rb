class AddBookingAgentIdToAgentBookings < ActiveRecord::Migration[6.0]
  def change
    add_reference :agent_bookings, :booking_agent, null: true, foreign_key: true
    remove_index :booking_agents, :code
    add_index :booking_agents, %i[code organisation_id], unique: true

    reversible do |direction|
      direction.up do 
        AgentBooking.find_each do |agent_booking| 
          booking_agent = agent_booking.organisation.booking_agents.find_by!(code: agent_booking.booking_agent_code)
          agent_booking.update(booking_agent: booking_agent)
        end
      end
    end
  end
end
