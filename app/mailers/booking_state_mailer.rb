class BookingStateMailer < ApplicationMailer
  def state_changed(booking, state)
    mail_from_template(state, interpolation_params(booking), to: booking.email)
  end
end
