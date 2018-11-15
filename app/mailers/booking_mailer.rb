class BookingMailer < ApplicationMailer
  def new_booking(booking)
    mail_from_template(:new_booking, interpolation_params(booking),
                       to: 'info@heimverwaltung.dev')
  end

  def booking_message(message)
    mail to: message.to, subject: message.subject do |format|
      format.text { message.markdown.to_text }
      format.html { message.markdown.to_html }
    end
  end

  # def confirm_request(booking_mailer_view_model)
  #   body = I18n.t(:'booking_mailer.confirm_request.body',
  #                 link: edit_public_booking_url(booking_mailer_view_model.booking))
  #   subject = I18n.t(:'booking_mailer.confirm_request.subject')
  #   mail(to: booking_mailer_view_model.to, subject: subject) do |format|
  #     format.text { body }
  #     # format.html { Kramdown::Document.new(body).to_html }
  #   end
  # end

  def booking_agent_request(booking_mailer_view_model)
    body = I18n.t(:'booking_mailer.booking_agent_request.body',
                  link: edit_public_booking_url(booking_mailer_view_model.booking))
    subject = I18n.t(:'booking_mailer.booking_agent_request.subject')
    mail(to: booking_mailer_view_model.to, subject: subject) do |format|
      format.text { body }
      # format.html { Kramdown::Document.new(body).to_html }
    end
  end

  def generic_notification(to, subject, body)
    mail(to: to, subject: subject) do |format|
      format.text { body }
      # format.html { Kramdown::Document.new(body).to_html }
    end
  end
end
