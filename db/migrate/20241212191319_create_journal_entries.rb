class CreateJournalEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :journal_entries do |t|
      t.references :invoice, null: false, foreign_key: true
      t.references :source, polymorphic: true, null: true
      # t.references :vat_category, null: true, foreign_key: true

      t.string :account_nr, null: false
      t.integer :side, null: false
      t.decimal :amount, null: false
      t.date :date, null: false
      t.string :text
      t.string :currency, null: false
      t.integer :ordinal
      t.string :source_document_ref
      # t.string :cost_center

      t.integer :book_type

      t.timestamps
    end
  end
end
