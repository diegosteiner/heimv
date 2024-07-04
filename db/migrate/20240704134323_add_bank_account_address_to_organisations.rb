class AddBankAccountAddressToOrganisations < ActiveRecord::Migration[7.1]
  def change
    add_column :organisations, :account_address, :string, null: true
  end
end
