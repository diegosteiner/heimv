class RecreateJournalEntries < ActiveRecord::Migration[8.0]
  def change
    remove_reference :journal_entries, :invoice_part, null: true
    remove_column :journal_entries, :account_nr, :string,  null: false
    remove_column :journal_entries, :side, :integer,  null: false
    remove_column :journal_entries, :amount, :decimal,  null: false
    remove_column :journal_entries, :text, :string
    remove_column :journal_entries, :ordinal, :integer

    add_column :journal_entries, :fragments, :jsonb, null: true
  end
end
