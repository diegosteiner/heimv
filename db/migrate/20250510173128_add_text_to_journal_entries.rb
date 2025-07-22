# frozen_string_literal: true

class AddTextToJournalEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :journal_entries, :text, :string, null: true
  end
end
