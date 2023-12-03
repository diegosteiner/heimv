class AddDeliveredAtToNotifications < ActiveRecord::Migration[7.1]
  def change
    add_column :notifications, :delivered_at, :datetime, null: true
    remove_column :notifications, :cc, :string, array: true
    remove_column :notifications, :bcc, :string
    remove_column :notifications, :addressed_to, :integer

    reversible do |direction|
      direction.up do
        Notification.update_all("delivered_at = sent_at")
      end
    end
  end
end
