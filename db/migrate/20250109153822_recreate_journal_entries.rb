class RecreateJournalEntries < ActiveRecord::Migration[8.0]
  def change
    remove_reference :journal_entries, :invoice_part, null: true
    remove_reference :journal_entries, :vat_category, null: true
    remove_column :journal_entries, :account_nr, :string
    remove_column :journal_entries, :side, :integer
    remove_column :journal_entries, :amount, :decimal
    remove_column :journal_entries, :text, :string
    remove_column :journal_entries, :ordinal, :integer
    remove_column :journal_entries, :book_type, :integer

    add_column :journal_entries, :fragments, :jsonb, null: true
  end
end
