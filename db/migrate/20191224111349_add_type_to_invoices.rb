class AddTypeToInvoices < ActiveRecord::Migration[6.0]
  def up
    Invoice.all.find_each do |invoice|
      invoice = invoice.becomes(Invoices::Invoice) if invoice.invoice?
      invoice = invoice.becomes(Invoices::Deposit) if invoice.deposit?
      invoice = invoice.becomes(Invoices::LateNotice) if invoice.late_notice?
    end
    remove_column :invoices, :invoice_type, :integer, null: false, default: 0
  end

  def down
    add_column :invoices, :invoice_type, :integer, null: false, default: 0
  end
end
