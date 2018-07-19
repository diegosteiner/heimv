class CreateInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices do |t|
      t.references :booking, foreign_key: true, type: :uuid
      t.datetime :issued_at, null: true
      t.datetime :payable_until, null: true
      t.text :text, null: true
      t.integer :invoice_type
      t.string :esr_number, null: true
      t.decimal :amount, default: 0

      t.timestamps
    end
  end
end
