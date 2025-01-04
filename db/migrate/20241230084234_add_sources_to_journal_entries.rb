class AddSourcesToJournalEntries < ActiveRecord::Migration[8.0]
  def change
    reversible do |direction|
      direction.up do
        JournalEntry.delete_all
      end
    end

    rename_column :journal_entries, :source_document_ref, :ref
    remove_column :journal_entries, :source_type, :string
    remove_column :journal_entries, :source_id, :integer
    add_reference :journal_entries, :invoice_part, null: true
    add_reference :journal_entries, :payment, null: true
    add_column :journal_entries, :trigger, :integer, null: false
    add_reference :journal_entries, :booking, type: :uuid, null: false
    add_column :journal_entries, :processed_at, :datetime, null: true
    change_column_null :journal_entries, :invoice_id, true, false
  end
end
