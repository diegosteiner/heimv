# frozen_string_literal: true

class RenameJournalEntries < ActiveRecord::Migration[8.0]
  def change
    rename_column :journal_entry_batches, :entries, :entries
    rename_table :journal_entry_batches, :journal_entry_batch_batches
  end
end
