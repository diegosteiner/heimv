class BookingMailer < ApplicationMailer
  def new_booking(booking)
    mail_from_template(:new_booking, interpolation_params(booking),
                       to: 'info@heimverwaltung.dev')
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

  protected

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def interpolation_params(booking)
    {
      edit_manage_booking_url: edit_manage_booking_url(booking.to_param),
      booking_details: begin
          <<~DETAILS

            - **Lagerhaus**: #{booking.home}
            - **Reservation**: #{I18n.l(booking.occupancy.begins_at)} bis  #{I18n.l(booking.occupancy.ends_at)}
            - **Organisation**: #{booking.organisation}
            - **Kontaktperson**:
              #{(booking.customer.address_lines + [booking.customer.phone, booking.customer.email]).join("\n")}
            - Bemerkungen: #{booking.remarks}
          DETAILS
        rescue StandardError
          ''
        end
    }
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
