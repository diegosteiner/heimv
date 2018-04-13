require_relative './base_seeder'

module Seeders
  class MailerTemplateSeeder < BaseSeeder
    def seed
      {
        mailer_templates: [
          MailerTemplate.create(
            mailer: BookingStateMailer,
            action: :new_request,
            subject: 'Pfadi-heime.ch: Bestätige Deine E-Mail-Adresse',
            body: <<~BODY
              ### Hallo

              Du hast soeben auf pfadi-heime.ch eine Mietanfrage begonnen. Bitte klicke auf den
              untenstehenden Link, um Deine E-Mail-Adresse zu bestätigen und um die
              Mietanfrage abzuschliessen.

              [%{edit_public_booking_url}](%{edit_public_booking_url})
              BODY
          ),
          MailerTemplate.create(
            mailer: BookingStateMailer,
            action: :confirmed_new_request,
            subject: 'Pfadi-heime.ch: Bestätige Deine E-Mail-Adresse',
            body: <<~BODY
              Hallo

              Hiermit bestätigen wir Deine Mietanfrage auf pfadi-heime.ch.

              Reservationsdetails:

              - Lagerhaus: Birchli, Einsiedeln
              - Reservation: 12.3.2018 18:00h bis 14.3.2018 18:00h
              - Organisation: Pfadi Laupen
              - Mietzweck: Lager/Kurs
              - Kontaktperson:
                Christian Kaiser / Murmel
                Stadtturmstrasse 15
                5400 Baden
                079 759 13 12
                murmel@pfadi-laupen.ch
              - Bemerkungen: Wir benötigen eine Bewilligung für die Autozufahrt.
              Deine Anfrage wird nun bearbeitet. Unser Heimverwalter wird sich in Kürze bei Dir melden.

              [%{edit_public_booking_url}](%{edit_public_booking_url})
              BODY
          )
        ]
      }
    end
  end
end
