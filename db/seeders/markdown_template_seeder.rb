require_relative './base_seeder'

module Seeders
  class MarkdownTemplateSeeder < BaseSeeder
    # rubocop:disable Metrics/MethodLength
    def seed
      {
        markdown_templates: [
          MarkdownTemplate.create!(
            key: MarkdownTemplate.key(:new_request),
            interpolatable_type: Message,
            locale: :'de-CH',
            title: 'Pfadi-heime.ch: Bestätige Deine E-Mail-Adresse',
            body: <<~BODY
              Hallo

              Du hast soeben auf pfadi-heime.ch eine Mietanfrage begonnen. Bitte klicke auf den
              untenstehenden Link, um Deine E-Mail-Adresse zu bestätigen und um die
              Mietanfrage abzuschliessen.

              [{{edit_public_booking_url}}]({{edit_public_booking_url}})

              Freundliche Grüsse

              Verein Pfadiheime St. Georg

              BODY
          ),
          MarkdownTemplate.create(
            key: MarkdownTemplate.key(:confirmed_new_request),
						interpolatable_type: Message,
            locale: :'de-CH',
            title: 'Pfadi-heime.ch: Bestätige Deine E-Mail-Adresse',
            body: <<~BODY
              Hallo

              Hiermit bestätigen wir Deine Mietanfrage auf pfadi-heime.ch.

              Reservationsdetails:
              {{booking_details}}

              Deine Anfrage wird nun bearbeitet. Unser Heimverwalter wird sich in Kürze bei Dir melden.

              [{{edit_public_booking_url}}]({{edit_public_booking_url}})

              Freundliche Grüsse

              Verein Pfadiheime St. Georg

              BODY
          ),
          MarkdownTemplate.create(
            key: MarkdownTemplate.key(:confirmed),
						interpolatable_type: Message,
            locale: :'de-CH',
            title: 'Pfadi-heime.ch: Reservation bestätigt',
            body: <<~BODY
              Hallo

              ???

              Bei Fragen oder Problemen kannst Du Dich jederzeit an unseren Heimverwalter
              wenden: Christian Morger / Smily, 079 262 25 48, info@pfadi-heime.ch

              Freundliche Grüsse
              Verein Pfadiheime St. Georg
              BODY
          ),
          MarkdownTemplate.create(
            key: MarkdownTemplate.key(:confirmed),
						interpolatable_type: Message,
            locale: :'de-CH',
            title: 'Pfadi-heime.ch: Provisorische Reservation bestätigt',
            body: <<~BODY
              Hallo

              Vielen Dank für Deine Mietanfrage auf pfadi-heime.ch. Wir haben Deine Angaben geprüft und nun eine provisorische Reservation erstellt.
              Diese gilt für 14 Tage, danach verfällt sie und das Lagerhaus wird wieder freigegeben.
              Über den folgenden Link kannst Du Deine Reservation verlängern, aufheben oder für definitiv erklären.

              [{{edit_public_booking_url}}]({{edit_public_booking_url}})

              Reservationsdetails:
              {{booking_details}}

              Bei Fragen oder Problemen kannst Du Dich jederzeit an unseren Heimverwalter
              wenden: Christian Morger / Smily, 079 262 25 48, info@pfadi-heime.ch

              Freundliche Grüsse
              Verein Pfadiheime St. Georg
              BODY
          ),
          # MarkdownTemplate.create(
          #   key: MarkdownTemplate.key(:definitive_request),
					# 	interpolatable_type: Message,
          #   locale: :'de-CH',
          #   title: 'Pfadi-heime.ch: Definitive Reservation bestätigt',
          #   body: <<~BODY
          #     Hallo

          #     Vielen Dank für Deine Mietanfrage auf pfadi-heime.ch. Wir haben Deine Angaben geprüft und nun eine provisorische Reservation erstellt.
          #     Diese gilt für 14 Tage, danach verfällt sie und das Lagerhaus wird wieder freigegeben.
          #     Über den folgenden Link kannst Du Deine Reservation verlängern, aufheben oder für definitiv erklären.

          #     [{{edit_public_booking_url}}]({{edit_public_booking_url}})

          #     Reservationsdetails:
          #     {{booking_details}}

          #     Bei Fragen oder Problemen kannst Du Dich jederzeit an unseren Heimverwalter
          #     wenden: Christian Morger / Smily, 079 262 25 48, info@pfadi-heime.ch

          #     Freundliche Grüsse
          #     Verein Pfadiheime St. Georg
          #     BODY
          # ),
          MarkdownTemplate.create(
            key: MarkdownTemplate.key(:new),
						interpolatable_type: Contract,
            locale: :'de-CH',
            title: 'Vertrag',
            body: <<~BODY
                # Allgemein
                Der Vermieter überlässt dem Mieter das Pfadiheim "{{ booking_home_name }}"" für den nachfolgend aufgeführten Anlass zur alleinigen Benutzung

                # Mietdauer
                **Mietbeginn**: {{ booking_occupancy_begins_at | datetime }}
                **Mietende**:   {{ booking_occupancy_ends_at | datetime }}

                Die Hausübergabe bzw. –rücknahme erfolgt durch den Heimwart. Der Mieter hat das Haus persönlich zum vereinbarten Zeitpunkt zu übernehmen resp. zu übergeben. Hierfür sind jeweils ca. 30 Minuten einzuplanen. Die Übernahme- und Rückgabezeiten sind unbedingt einzuhalten.

                Verspätungen ab 15 Minuten werden mit CHF 20.- pro angebrochene Viertelstunde verrechnet!

                Der genaue Zeitpunkt der Hausübernahme ist mit dem Heimwart spätestens 5 Tage vor Mietbeginn telefonisch zu vereinbaren:

                *{{ booking_home_janitor }}*

                # Übernahme und Rückgabe
                Die Übernahme- und Rückgabezeiten sind unbedingt einzuhalten. Verspätungen ab 15 Minuten werden mit CHF 20.- pro angebrochene Viertelstunde verrechnet!

                # Zweck der Miete
                *{{ booking_purpose }}*

                # Tarife
                Die Mindestbelegung beträgt durchschnittlich 12 Personen pro Nacht.

                # Anzahlung
                Die Anzahlung wird bei Abschluss des Vertrages fällig
              BODY
          )
        ]
      }
    end
    # rubocop:enable Metrics/MethodLength
  end
end
