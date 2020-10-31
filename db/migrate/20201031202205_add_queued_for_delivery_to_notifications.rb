class AddQueuedForDeliveryToNotifications < ActiveRecord::Migration[6.0]
  def change
    add_column :notifications, :queued_for_delivery, :boolean, default: false
  end
end
