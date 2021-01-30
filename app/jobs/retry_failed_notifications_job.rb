# frozen_string_literal: true

class RetryFailedNotificationsJob < ApplicationJob
  queue_as :default

  def perform(notifications = Notification.failed.where(created_at: (15.minutes.ago)..(1.day.ago)))
    notifications.find_each(&:deliver)
    true
  end
end
