class AddTypeToInvoices < ActiveRecord::Migration[6.0]
  def up
    Invoice.all.find_each do |invoice|
      invoice = invoice.becomes(Invoices::Invoice) if invoice.respond_to?(:invoice?) && invoice.invoice?
      invoice = invoice.becomes(Invoices::Deposit) if invoice.respond_to?(:deposit?) && invoice.deposit?
      invoice = invoice.becomes(Invoices::LateNotice) if invoice.respond_to?(:late_notice?) && invoice.late_notice?
    end
    remove_column :invoices, :invoice_type, :integer, null: false, default: 0
  end

  def down
    add_column :invoices, :invoice_type, :integer, null: false, default: 0
  end
end
