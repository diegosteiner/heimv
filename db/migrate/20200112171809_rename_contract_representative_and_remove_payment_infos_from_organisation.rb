class RenameContractRepresentativeAndRemovePaymentInfosFromOrganisation < ActiveRecord::Migration[6.0]
  def change
    rename_column :organisations, :contract_representative_address, :representative_address
    remove_column :organisations, :payment_information, :text, null: true
  end
end
