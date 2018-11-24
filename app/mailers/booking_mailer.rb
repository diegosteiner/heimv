class BookingMailer < ApplicationMailer
  def new_booking(booking, interpolator = Interpolator.new(booking))
    subject = I18n.t(:'booking_mailer.new_booking.subject')
    begin
      markdown = Markdown.new(I18n.t(:'booking_mailer.new_booking.body', interpolator.to_h.symbolize_keys))
    rescue I18n::MissingInterpolationArgument => ex
      markdown = Markdown.new(ex.message)
    end
    markdown_mail('info@heimverwalung.example.com', subject, markdown)
  end

  def booking_message(message)
    message.attachments.each { |attachment| attachments[attachment.filename.to_s] = attachment.blob.download }
    markdown_mail(message.to, message.subject, message.markdown)
  end

  def booking_agent_request(booking_mailer_view_model)
    body = I18n.t(:'booking_mailer.booking_agent_request.body',
                  link: edit_public_booking_url(booking_mailer_view_model.booking))
    subject = I18n.t(:'booking_mailer.booking_agent_request.subject')
    mail(to: booking_mailer_view_model.to, subject: subject) do |format|
      format.text { body }
      format.html { Kramdown::Document.new(body).to_html }
    end
  end
end
