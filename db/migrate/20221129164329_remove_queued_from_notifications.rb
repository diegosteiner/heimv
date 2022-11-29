class RemoveQueuedFromNotifications < ActiveRecord::Migration[7.0]
  def change
    remove_column :notifications, :queued_for_delivery, :boolean, default: false
  end
end
