class AddBookingsWithoutInvoicesToTenants < ActiveRecord::Migration[7.1]
  def change
    add_column :tenants, :bookings_without_invoice, :boolean, default: false
    rename_column :tenants, :allow_bookings_without_contract, :bookings_without_contract
    remove_column :tenants, :iban, :string, null: true
  end
end
