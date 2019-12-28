class BookingMailer < ApplicationMailer
  def new_booking(booking)
    template = MarkdownTemplate.find_by(key: :manage_new_booking_mail)
    organisation = booking.organisation
    markdown_mail(organisation, template.interpolate('booking' => booking), to: to, subject: template.title)
  end

  def booking_message(message)
    organisation = message.booking.organisation
    message.attachments.each { |attachment| attachments[attachment.filename.to_s] = attachment.blob.download }
    markdown_mail(organisation, message.markdown, to: message.to, subject: message.subject, cc: message.cc)
  end
end
