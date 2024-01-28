class AddIBANToOrganisationsAndTenants < ActiveRecord::Migration[6.1]
  def change
    add_column :tenants, :iban, :string, null: true
    add_column :organisations, :qr_iban, :string, null: true
    add_column :bookings, :conditions_accepted_at, :datetime, null: true
  end
end
