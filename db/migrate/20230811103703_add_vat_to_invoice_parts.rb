class AddVatToInvoiceParts < ActiveRecord::Migration[7.0]
  def change
    add_column :invoice_parts, :vat, :decimal, null: true
  end
end
