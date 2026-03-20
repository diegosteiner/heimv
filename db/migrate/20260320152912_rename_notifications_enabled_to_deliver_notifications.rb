# frozen_string_literal: true

class RenameNotificationsEnabledToDeliverNotifications < ActiveRecord::Migration[8.1]
  def change
    rename_column :organisations, :notifications_enabled, :deliver_notifications
    rename_column :bookings, :notifications_enabled, :deliver_notifications
  end
end
