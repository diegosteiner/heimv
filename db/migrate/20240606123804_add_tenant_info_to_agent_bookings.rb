class AddTenantInfoToAgentBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :agent_bookings, :tenant_infos, :text
  end
end
