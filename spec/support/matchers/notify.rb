# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :notify do |mail_template|
  def matching_notification(booking, key, to)
    notifications = booking.notifications.joins(:mail_template).where(mail_template: { key: })
    notifications = notifications.where(to:) if to.present?
    notifications.take
  end

  match do |actual|
    notification = matching_notification(actual, mail_template, @to)
    next false if notification.blank? || !notification.valid?
    next false if (@save || @deliver) && !notification.persisted?
    next false if @deliver && notification.instance_variable_get(:@message_delivery).blank?

    true
  end

  failure_message do |booking|
    notification = matching_notification(booking, mail_template, @to)
    next "Notification '#{mail_template}' to #{@to} not found for booking #{booking.to_param}" if notification.blank?
    next "Notification '#{mail_template}' to #{@to} not valid" unless notification.valid?

    "Notification '#{mail_template}' does not match"
  end

  chain :and_deliver do
    @deliver = true
  end

  chain :and_save do
    @save = true
  end

  chain :to do |to|
    @to = to.to_sym
  end
end
