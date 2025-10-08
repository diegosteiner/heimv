# frozen_string_literal: true

class RetryPendingNotificationsJob < ApplicationJob
  def perform
    retry_range = (4.hours.ago)..(1.hour.ago)
    pending_notifications = Notification.where(delivered_at: nil, sent_at: retry_range)
    Rails.logger.info("#{pending_notifications.count} pending notifications")
    pending_notifications.each { it.send(:message_delivery).send(:deliver_later) }
  end
end
