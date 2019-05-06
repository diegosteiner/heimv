class BookingMailer < ApplicationMailer
  def new_booking(booking)
    to = ENV.fetch('ADMIN_EMAIL', 'info@heimverwalung.example.com')
    template = MarkdownTemplate.find_by(key: :manage_new_booking_mail)
    markdown_mail(to, template.title, template.interpolate('booking' => booking))
  end

  def booking_message(message)
    message.attachments.each { |attachment| attachments[attachment.filename.to_s] = attachment.blob.download }
    markdown_mail(message.to, message.subject, message.markdown, { cc: message.cc, bcc: message.bcc})
  end
end
