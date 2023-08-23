# frozen_string_literal: true

class OrganisationMailer < ApplicationMailer
  BOOKING_HEADER_NAME = 'X-Heimv-Booking-Id'
  NOTIFICATION_HEADER_NAME = 'X-Heimv-Notification-Id'

  default from: -> { (@organisation.mail_from || @organisation.email) },
          reply_to: -> { @organisation.email },
          charset: 'UTF-8'

  before_action :set_organisation
  after_action :set_delivery_options

  def booking_email(notification)
    @organisation = notification.organisation
    @notification = notification
    return if @notification.blank?

    set_headers
    attach_active_storage_attachments(notification.attachments)
    mail(to: notification.to, cc: notification.cc, bcc: notification.bcc, subject: notification.subject) do |format|
      format.text { render plain: @notification.text }
      # rubocop:disable Rails/OutputSafety
      format.html { render html:  @notification.body&.html_safe }
      # rubocop:enable Rails/OutputSafety
    end
  end

  def test_smtp_settings_email(test_string = 'Test')
    mail(to: @organisation.email, subject: test_string, body: test_string, text: test_string)
  end

  protected

  def attach_active_storage_attachments(values)
    values.map do |attachment|
      next unless attachment.present? && attachment.filename.present?

      attachments[attachment.filename.to_s] = attachment.blob.download
    end
  end

  def set_headers
    headers[NOTIFICATION_HEADER_NAME] = @notification.to_param
    headers[BOOKING_HEADER_NAME] = @notification.booking.to_param
  end

  def set_delivery_options
    return unless Rails.env.production? && @organisation.smtp_settings.present?

    mail.delivery_method.settings.merge!(@organisation.smtp_settings.to_h)
  end

  # rubocop:disable Naming/MemoizedInstanceVariableName
  def set_organisation
    @organisation ||= params
  end
  # rubocop:enable Naming/MemoizedInstanceVariableName

  class DeliveryObserver
    def self.delivered_email(mail)
      notification = Notification.find_by(id: mail.header[NOTIFICATION_HEADER_NAME]&.value)

      # rubocop:disable Rails/SkipsModelValidations
      notification&.touch(:sent_at)
      # rubocop:enable Rails/SkipsModelValidations
    end
  end

  register_observer DeliveryObserver
end
