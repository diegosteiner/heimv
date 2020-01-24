class RenameExtendableToPostponableForInDeadlines < ActiveRecord::Migration[6.0]
  def change
    rename_column :deadlines, :extendable, :postponable_for
  end
end
