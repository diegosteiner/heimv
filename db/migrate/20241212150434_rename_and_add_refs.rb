class RenameAndAddRefs < ActiveRecord::Migration[8.0]
  def change
    rename_column :invoices, :ref, :payment_ref
    add_column :invoices, :ref, :string, null: true
    add_column :tenants, :ref, :string, null: true
  end
end
