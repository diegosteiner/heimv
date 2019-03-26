class AddRemarksToDeadlines < ActiveRecord::Migration[5.2]
  def change
    add_column :deadlines, :remarks, :text, null: true
  end
end
