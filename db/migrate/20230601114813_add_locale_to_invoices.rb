class AddLocaleToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :locale, :string, null: true
    add_column :contracts, :locale, :string, null: true
  end
end
