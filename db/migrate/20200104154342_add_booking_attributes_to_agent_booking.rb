class AddBookingAttributesToAgentBooking < ActiveRecord::Migration[6.0]
  def up
    add_reference :agent_bookings, :home, null: true, foreign_key: true
    add_reference :agent_bookings, :organisation, null: true, foreign_key: true
    add_column :agent_bookings, :tenant_email, :string

    AgentBooking.find_each do |agent_booking|
      agent_booking.tenant_email = agent_booking.booking&.email
      agent_booking.home = agent_booking.booking&.home
      agent_booking.organisation = agent_booking.booking&.organisation
      agent_booking.save
    end
  end

  def down
    remove_reference :agent_bookings, :home, null: true, foreign_key: true
    remove_reference :agent_bookings, :organisation, null: true, foreign_key: true
    remove_column :agent_bookings, :tenant_email, :string
  end


end
