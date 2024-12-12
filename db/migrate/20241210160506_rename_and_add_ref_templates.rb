class RenameAndAddRefTemplates < ActiveRecord::Migration[8.0]
  def change
    rename_column :organisations, :invoice_ref_template, :invoice_payment_ref_template
    add_column :organisations, :invoice_ref_template, :string, null: true
    add_column :organisations, :tenant_ref_template, :string, null: true
  end
end
