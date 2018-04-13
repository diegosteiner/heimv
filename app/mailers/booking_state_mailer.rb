class BookingStateMailer < ApplicationMailer
  def state_changed(booking, state)
    template = MailerTemplate.where(mailer: self.class.to_s, action: state).take
    return unless template

    @booking = booking
    interpolation = {
      edit_public_booking_url: edit_public_booking_url(booking.to_param)
    }


    mail(to: booking.customer&.email || booking.email, subject: template.subject) do |format|
      format.text { template.text_body(interpolation) }
      format.html { template.html_body(interpolation) }
    end
  end
end
