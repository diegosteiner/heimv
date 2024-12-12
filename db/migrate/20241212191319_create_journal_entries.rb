class CreateJournalEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :journal_entries do |t|
      t.uuid :booking_id, null: false
      t.references :source, polymorphic: true, null: false
      t.string :account_nr, null: false
      t.references :vat_category, null: true, foreign_key: true
      t.date :date, null: false
      t.decimal :amount, null: false
      t.integer :side, null: false
      t.string :currency, null: false
      t.string :text
      t.integer :ordinal
      t.string :source_document_ref
      t.string :cost_center

      t.timestamps
    end
  end
end
