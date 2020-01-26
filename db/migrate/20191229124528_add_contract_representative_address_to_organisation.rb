class AddContractRepresentativeAddressToOrganisation < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :contract_representative_address, :string, null: true
  end
end
