# frozen_string_literal: true

class BookingMailer < OrganisationMailer
  # default from: -> { (@organisation.mail_from || organisation.email) },
  #         reply_to: -> { @organisation.email },
  #         charset: 'UTF-8'

  # after_action :set_delivery_options

  def notification
    mail(to: @notification.to, subject: @notification.subject, cc: @notification.cc, bcc: @notification.bcc,
         attachments: @notification.prepare_attachments_for_mail) do |format|
      format.html
      format.text { render plain: @notification.text }
    end
  end

  protected

  def set_notification
    @notification = params[:notification]
  end

  # rubocop:disable Naming/MemoizedInstanceVariableName
  def set_organisation
    @organisation ||= set_notification&.organisation
  end
  # rubocop:enable Naming/MemoizedInstanceVariableName
end
