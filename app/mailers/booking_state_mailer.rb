class BookingStateMailer < ApplicationMailer
  def state_changed(booking, state)
    template = MailerTemplate.where(mailer: self.class.to_s, action: state).take
    return unless template

    @booking = booking
    mail(to: booking.customer&.email || booking.email, subject: template.subject) do |format|
      format.text { template.text_body(interpolation_params(booking)) }
      format.html { template.html_body(interpolation_params(booking)) }
    end
  end

  private

  def interpolation_params(booking)
    {
      edit_public_booking_url: edit_public_booking_url(booking.to_param)
    }
  end
end
