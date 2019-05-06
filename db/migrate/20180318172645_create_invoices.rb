class CreateInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices do |t|
      t.string :type, index: true
      t.references :booking, foreign_key: true, type: :uuid
      t.datetime :issued_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :payable_until, null: true
      t.datetime :sent_at, null: true
      t.text :text, null: true
      t.integer :invoice_type
      t.string :ref, null: true, index: true
      t.decimal :amount, default: 0
      t.boolean :paid, default: false
      t.boolean :print_payment_slip, default: false
      t.datetime :deleted_at, null: true

      t.timestamps
    end
  end
end
