require_relative './base_seeder'

module Seeders
  class MarkdownTemplateSeeder < BaseSeeder
    # rubocop:disable Metrics/MethodLength
    def seed
      {
        markdown_templates: [
          MarkdownTemplate.create!(
            key: MarkdownTemplate.composite_key(BookingStateMailer, :new_request),
            locale: :de,
            title: 'Pfadi-heime.ch: Bestätige Deine E-Mail-Adresse',
            body: <<~BODY
              ### Hallo

              Du hast soeben auf pfadi-heime.ch eine Mietanfrage begonnen. Bitte klicke auf den
              untenstehenden Link, um Deine E-Mail-Adresse zu bestätigen und um die
              Mietanfrage abzuschliessen.

              [%{edit_public_booking_url}](%{edit_public_booking_url})

              Freundliche Grüsse

              Verein Pfadiheime St. Georg

              BODY
          ),
          MarkdownTemplate.create(
            key: MarkdownTemplate.composite_key(BookingStateMailer, :confirmed_new_request),
            locale: :de,
            title: 'Pfadi-heime.ch: Bestätige Deine E-Mail-Adresse',
            body: <<~BODY
              Hallo

              Hiermit bestätigen wir Deine Mietanfrage auf pfadi-heime.ch.

              Reservationsdetails:
              %{booking_details}

              Deine Anfrage wird nun bearbeitet. Unser Heimverwalter wird sich in Kürze bei Dir melden.

              [%{edit_public_booking_url}](%{edit_public_booking_url})

              Freundliche Grüsse

              Verein Pfadiheime St. Georg

              BODY
          ),
          MarkdownTemplate.create(
            key: MarkdownTemplate.composite_key(BookingStateMailer, :provisional_request),
            locale: :de,
            title: 'Pfadi-heime.ch: Provisorische Reservation bestätigt',
            body: <<~BODY
              Hallo

              Vielen Dank für Deine Mietanfrage auf pfadi-heime.ch. Wir haben Deine Angaben geprüft und nun eine provisorische Reservation erstellt.
              Diese gilt für 14 Tage, danach verfällt sie und das Lagerhaus wird wieder freigegeben.
              Über den folgenden Link kannst Du Deine Reservation verlängern, aufheben oder für definitiv erklären.

              [%{edit_public_booking_url}](%{edit_public_booking_url})

              Reservationsdetails:
              %{booking_details}

              Bei Fragen oder Problemen kannst Du Dich jederzeit an unseren Heimverwalter
              wenden: Christian Morger / Smily, 079 262 25 48, info@pfadi-heime.ch

              Freundliche Grüsse
              Verein Pfadiheime St. Georg
              BODY
          ),
          MarkdownTemplate.create(
            key: MarkdownTemplate.composite_key(BookingMailer, :new_booking),
            locale: :de,
            title: 'Pfadi-heime.ch: Neue Mietanfrage',
            body: <<~BODY
              Hallo

              Es ist eine neue Mietanfrage eingegangen

              [%{edit_manage_booking_url}](%{edit_manage_booking_url})

              Reservationsdetails:
              %{booking_details}

              Freundliche Grüsse

              Verein Pfadiheime St. Georg

              BODY
          )
        ]
      }
    end
    # rubocop:enable Metrics/MethodLength
  end
end
