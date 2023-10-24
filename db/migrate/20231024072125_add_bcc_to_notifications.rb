class AddBccToNotifications < ActiveRecord::Migration[7.1]
  def change
    add_column :notifications, :bcc, :string, null: true
  end
end
