class AddCreditorAddressToOrganisations < ActiveRecord::Migration[7.0]
  def change
    add_column :organisations, :creditor_address, :text, null: true
  end
end
