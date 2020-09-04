class RenameMessagesToNotifications < ActiveRecord::Migration[6.0]
  def change
    rename_table :messages, :notifications
    rename_column :organisations, :message_footer, :notification_footer
    rename_column :organisations, :messages_enabled, :notifications_enabled
    rename_column :bookings, :messages_enabled, :notifications_enabled
  end
end
