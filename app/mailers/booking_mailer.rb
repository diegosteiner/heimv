class BookingMailer < ApplicationMailer
  default from: Rails.application.secrets.mail_from

  def confirm_request(booking_mailer_view_model)
    body = I18n.t(:'booking_mailer.confirm_request.body',
                  link: edit_public_booking_url(booking_mailer_view_model.public_id))
    subject = I18n.t(:'booking_mailer.confirm_request.subject')
    mail(to: booking_mailer_view_model.to, subject: subject) do |format|
      format.text { body }
      # format.html { Kramdown::Document.new(body).to_html }
    end
  end

  def booking_agent_request(booking_mailer_view_model)
    body = I18n.t(:'booking_mailer.booking_agent_request.body',
                  link: edit_public_booking_url(booking_mailer_view_model.public_id))
    subject = I18n.t(:'booking_mailer.booking_agent_request.subject')
    mail(to: booking_mailer_view_model.to, subject: subject) do |format|
      format.text { body }
      # format.html { Kramdown::Document.new(body).to_html }
    end
  end

  protected

  def markdown_mail(mail_id, booking_mailer_view_model)
    body = I18n.t("booking_mailer.#{mail_id}.body")
    subject = I18n.t("booking_mailer.#{mail_id}.subject")
    mail(to: booking_mailer_view_model.to, subject: subject) do |format|
      format.text { body }
      # TODO: Add support for richt emails
      # format.html { Kramdown::Document.new(body).to_html }
    end
  end
end
