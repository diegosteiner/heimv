class AddSupersedeInvoiceIdToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_reference :invoices, :supersede_invoice, null: true, foreign_key: { to_table: :invoices }
  end
end
