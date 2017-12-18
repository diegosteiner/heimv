class BookingMailer < ApplicationMailer
  default from: Rails.application.secrets.mail_from
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.booking_mailer.confirm_request.subject
  #
  def confirm_request(booking_mailer_view_model)
    markdown_mail(:confirm_request, booking_mailer_view_model)
  end

  protected

  def markdown_mail(mail_id, booking_mailer_view_model)
    body = I18n.t("booking_mailer.#{mail_id}.body")
    subject = I18n.t("booking_mailer.#{mail_id}.subject")
    mail(to: booking_mailer_view_model.to, subject: subject) do |format|
      format.text { body }
      format.html { Kramdown::Document.new(body).to_html }
    end
  end
end
