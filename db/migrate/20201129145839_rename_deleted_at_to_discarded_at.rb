class RenameDeletedAtToDiscardedAt < ActiveRecord::Migration[6.0]
  def change
    rename_column :invoices, :deleted_at, :discarded_at
    add_index :invoices, :discarded_at
  end
end
