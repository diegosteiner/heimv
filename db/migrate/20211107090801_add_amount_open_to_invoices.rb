class AddAmountOpenToInvoices < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :amount_open, :decimal, null: true
    Invoice.find_each { |invoice| invoice.recalculate! }
    remove_column :invoices, :paid, :boolean, default: false
  end
end
