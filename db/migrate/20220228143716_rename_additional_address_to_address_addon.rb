class RenameAdditionalAddressToAddressAddon < ActiveRecord::Migration[7.0]
  def change
    rename_column :tenants, :additional_address, :address_addon
  end
end
