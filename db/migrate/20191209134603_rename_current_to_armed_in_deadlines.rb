class RenameCurrentToArmedInDeadlines < ActiveRecord::Migration[6.0]
  def change
    rename_column :deadlines, :current, :armed
  end
end
