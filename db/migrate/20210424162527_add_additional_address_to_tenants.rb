class AddAdditionalAddressToTenants < ActiveRecord::Migration[6.1]
  def change
    add_column :tenants, :additional_address, :string, null: true
  end
end
