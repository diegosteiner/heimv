class RemoveAgentAttributesFromBooking < ActiveRecord::Migration[5.2]
  def change
    remove_column :bookings, :booking_agent_code, :string, null: true
    remove_column :bookings, :booking_agent_ref, :string, null: true
  end
end
