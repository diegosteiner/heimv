class BookingStateMailer < ApplicationMailer
  def state_changed(booking, state)
    mail_from_template(state, interpolation_params(booking), to: booking.email)
  end

  private

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def interpolation_params(booking)
    {
      edit_public_booking_url: edit_public_booking_url(booking.to_param),
      booking_details: begin
          <<~DETAILS

            - **Lagerhaus**: #{booking.home}
            - **Reservation**: #{I18n.l(booking.occupancy.begins_at)} bis  #{I18n.l(booking.occupancy.ends_at)}
            - **Organisation**: #{booking.organisation}
            - **Kontaktperson**: #{(booking.customer.address_lines + [booking.customer.phone, booking.customer.email]).flatten.join(",")}
            - **Bemerkungen**: #{booking.remarks}

          DETAILS
        rescue StandardError
          ''
        end
    }
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
