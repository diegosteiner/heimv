class AddAccountingInformation < ActiveRecord::Migration[7.2]
  def change
    add_column :tenants, :accounting_account_nr, :string, null: true
    rename_column :tarifs, :accountancy_account, :accounting_account_nr
  end
end
