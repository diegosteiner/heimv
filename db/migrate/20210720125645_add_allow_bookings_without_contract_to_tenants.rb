class AddAllowBookingsWithoutContractToTenants < ActiveRecord::Migration[6.1]
  def change
    add_column :tenants, :allow_bookings_without_contract, :boolean, default: false
  end
end
