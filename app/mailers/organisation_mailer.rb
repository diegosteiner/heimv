# frozen_string_literal: true

class OrganisationMailer < ApplicationMailer
  default from: -> { (@organisation.mail_from || @organisation.email) },
          reply_to: -> { @organisation.email },
          charset: 'UTF-8'

  before_action :set_organisation
  after_action :set_delivery_options

  def booking_email(notification)
    @organisation = notification.organisation
    @notification = notification
    prepared_attachments = notification.attachments.to_h do |attachment|
      [attachment.filename.to_s, attachment.blob.download]
    end

    mail(to: notification.to, cc: notification.cc, bcc: notification.bcc,
         subject: notification.subject, attachments: prepared_attachments) do |format|
      format.text { render plain: @notification.text }
      format.html
    end
  end

  def test_smtp_settings_email(test_string = 'Test')
    mail(to: @organisation.email, subject: test_string, body: test_string, text: test_string)
  end

  protected

  def set_delivery_options
    mail.delivery_method.settings.merge!(@organisation.smtp_settings.to_h) if @organisation.smtp_settings.present?
  end

  # rubocop:disable Naming/MemoizedInstanceVariableName
  def set_organisation
    @organisation ||= params
  end
  # rubocop:enable Naming/MemoizedInstanceVariableName
end
