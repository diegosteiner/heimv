require_relative './base_seeder'

module Seeders
  class MarkdownTemplateSeeder < BaseSeeder
    # rubocop:disable Metrics/MethodLength
    def seed
      {
        markdown_templates: [
          MarkdownTemplate.create!(
            key: :unconfirmed_request_message,
            locale: :'de-CH',
            title: 'Pfadi-heime.ch: Bestätige Deine E-Mail-Adresse',
            body: <<~BODY
              Hallo

              Du hast soeben auf pfadi-heime.ch eine Mietanfrage begonnen. Bitte klicke auf den
              untenstehenden Link, um Deine E-Mail-Adresse zu bestätigen und um die
              Mietanfrage abzuschliessen.

              [{{booking.links.edit}}]({{booking.links.edit}})

              Freundliche Grüsse

              Verein Pfadiheime St. Georg

              BODY
          ),
          MarkdownTemplate.create!(
            key: :open_request_message,
            locale: :'de-CH',
            title: 'Pfadi-heime.ch: Bestätigung Deiner Mietanfrage',
            body: <<~BODY
              {{ booking.tenant.salutation_name }}

              Hiermit bestätigen wir Deine Mietanfrage auf pfadi-heime.ch.


              **Reservationsdetails**

              - Lagerhaus: {{booking.home.name}}, {{ booking.home.place }}
              - Reservation: {{ booking.occupancy.begins_at | date: "%d.%m.%Y %H:%M" }} bis {{ booking.occupancy.ends_at | date: "%d.%m.%Y %H:%M" }}
              - Organisation: {{ booking.organisation }}
              - Mietzweck: {{ booking.purpose }}
              - Bemerkungen: {{ booking.remarks }}


              Deine Anfrage wird nun bearbeitet. Unser Heimverwalter wird sich in Kürze bei Dir melden.

              [{{booking.links.edit}}]({{booking.links.edit}})

              Freundliche Grüsse

              Verein Pfadiheime St. Georg

              BODY
          ),
          MarkdownTemplate.create!(
            key: :confirmed_message,
            locale: :'de-CH',
            title: 'Pfadi-heime.ch: Reservation bestätigt',
            body: <<~BODY
              {{ booking.tenant.salutation_name }}

              Mit dieser Nachricht erhältst Du die Unterlagen für Deine Lagerhaus-Reservation. Bitte lies die Dokumente durch und prüfe, ob alle Daten korrekt sind. Unterschreibe dann den Mietvertrag und sende ihn an uns zurück.
              Falls im Vertrag eine Anzahlung vereinbart wurde, ist diese sofort fällig. Bitte beachte, dass der Vertrag erst zustande kommt, wenn Anzahlung und unterzeichnetes Vertragsdoppel bei uns angekommen sind.


              **Reservationsdetails**

              - Lagerhaus: {{booking.home.name}}, {{ booking.home.place }}
              - Reservation: {{ booking.occupancy.begins_at | date: "%d.%m.%Y %H:%M" }} bis {{ booking.occupancy.ends_at | date: "%d.%m.%Y %H:%M" }}
              - Organisation: {{ booking.organisation }}
              - Mietzweck: {{ booking.purpose }}
              - Bemerkungen: {{ booking.remarks }}


              **Zahlungsdetails**

              - Empfänger: Verein Pfadiheime St. Georg, Zürich
              - Konto: XXXXXX


              Bei Fragen oder Problemen kannst Du Dich jederzeit an unseren Heimverwalter
              wenden: Christian Morger / Smily, 079 262 25 48, info@pfadi-heime.ch

              Freundliche Grüsse
              Verein Pfadiheime St. Georg
              BODY
          ),
          MarkdownTemplate.create!(
            key: :provisional_request_message,
            locale: :'de-CH',
            title: 'Pfadi-heime.ch: Provisorische Reservation bestätigt',
            body: <<~BODY
              {{ booking.tenant.salutation_name }}

              Vielen Dank für Deine Mietanfrage auf pfadi-heime.ch. Wir haben Deine Angaben geprüft und nun eine provisorische Reservation erstellt.
              Diese gilt für **14 Tage**, danach verfällt sie und das Lagerhaus wird wieder freigegeben.
              Über den folgenden Link kannst Du Deine Reservation verlängern, aufheben oder für definitiv erklären.

              [{{booking.links.edit}}]({{booking.links.edit}})


              **Reservationsdetails**

              - Lagerhaus: {{booking.home.name}}, {{ booking.home.place }}
              - Reservation: {{ booking.occupancy.begins_at | date: "%d.%m.%Y %H:%M" }} bis {{ booking.occupancy.ends_at | date: "%d.%m.%Y %H:%M" }}
              - Organisation: {{ booking.organisation }}
              - Mietzweck: {{ booking.purpose }}
              - Bemerkungen: {{ booking.remarks }}


              Bei Fragen oder Problemen kannst Du Dich jederzeit an unseren Heimverwalter
              wenden: Christian Morger / Smily, 079 262 25 48, info@pfadi-heime.ch

              Freundliche Grüsse
              Verein Pfadiheime St. Georg
              BODY
          ),
          MarkdownTemplate.create!(
            key: :overdue_request_message,
            locale: :'de-CH',
            title: 'Pfadi-heime.ch: Anfrage überfällig',
            body: <<~BODY
              {{ booking.tenant.salutation_name }}

              Du hast kürzlich auf pfadi-heime.ch eine provisorische Reservation erstellt.
              Eine Reservation gilt für 14 Tage. Wenn sie in dieser Zeit nicht verlängert wird, verfällt sie und das Lagerhaus wird wieder freigegeben.
              Wir geben Dir nochmals 3 Tage Zeit, um Deine Reservation zu verlängern oder um sie definitiv zumachen.
              Klicke dazu auf den untenstehenden Link

              [{{booking.links.edit}}]({{booking.links.edit}})


              **Reservationsdetails**

              - Lagerhaus: {{booking.home.name}}, {{ booking.home.place }}
              - Reservation: {{ booking.occupancy.begins_at | date: "%d.%m.%Y %H:%M" }} bis {{ booking.occupancy.ends_at | date: "%d.%m.%Y %H:%M" }}
              - Organisation: {{ booking.organisation }}
              - Mietzweck: {{ booking.purpose }}
              - Bemerkungen: {{ booking.remarks }}


              Deine Anfrage wird nun bearbeitet. Unser Heimverwalter wird sich in Kürze bei Dir melden.

              [{{booking.links.edit}}]({{booking.links.edit}})

              Freundliche Grüsse

              Verein Pfadiheime St. Georg

              BODY
          ),
          MarkdownTemplate.create!(
            key: :definitive_request_message,
            locale: :'de-CH',
            title: 'Pfadi-heime.ch: Definitive Reservation bestätigt',
            body: <<~BODY
              Hallo

              Vielen Dank für Deine Mietanfrage auf pfadi-heime.ch. Wir haben Deine Angaben geprüft und nun eine definitive Reservation erstellt. Unser Heimverwalter wird Dir in den nächsten Tagen den Mietvertrag zustellen.

              [{{booking.links.edit}}]({{booking.links.edit}})


              **Reservationsdetails**

              - Lagerhaus: {{booking.home.name}}, {{ booking.home.place }}
              - Reservation: {{ booking.occupancy.begins_at | date: "%d.%m.%Y %H:%M" }} bis {{ booking.occupancy.ends_at | date: "%d.%m.%Y %H:%M" }}
              - Organisation: {{ booking.organisation }}
              - Mietzweck: {{ booking.purpose }}
              - Bemerkungen: {{ booking.remarks }}


              Bei Fragen oder Problemen kannst Du Dich jederzeit an unseren Heimverwalter
              wenden: Christian Morger / Smily, 079 262 25 48, info@pfadi-heime.ch

              Freundliche Grüsse
              Verein Pfadiheime St. Georg
              BODY
          ),
          MarkdownTemplate.create!(
            key: :manage_new_booking_mail,
            locale: :'de-CH',
            title: 'Pfadi-heime.ch: Neue Mietanfrage',
            body: <<~BODY
              Hallo

              Es ist eine neue Mietanfrage eingegangen für das Lagerhaus "%{booking.home.name}"

              [{{booking.links.edit}}]({{booking.links.edit}})

              **Reservationsdetails**

              - Lagerhaus: {{booking.home.name}}, {{ booking.home.place }}
              - Reservation: {{ booking.occupancy.begins_at | date: "%d.%m.%Y %H:%M" }} bis {{ booking.occupancy.ends_at | date: "%d.%m.%Y %H:%M" }}
              - Organisation: {{ booking.organisation }}
              - Mietzweck: {{ booking.purpose }}
              - Bemerkungen: {{ booking.remarks }}

              Freundliche Grüsse

              Verein Pfadiheime St. Georg

              BODY
          ),
          MarkdownTemplate.create!(
            key: :upcoming_message,
            locale: :'de-CH',
            title: 'Pfadi-heime.ch: Anzahlung und Vertragsdoppel eingegangen',
            body: <<~BODY
              {{ booking.tenant.salutation_name }}

              Wir haben das von Dir unterzeichnete Vertragsdoppel erhalten. Damit steht deinem Anlass nichts mehr im Weg. Wir wünschen Dir und Deiner Gruppe einen schönen Aufenthalt in unserem Lagerhaus.


              **Reservationsdetails**

              - Lagerhaus: {{booking.home.name}}, {{ booking.home.place }}
              - Reservation: {{ booking.occupancy.begins_at | date: "%d.%m.%Y %H:%M" }} bis {{ booking.occupancy.ends_at | date: "%d.%m.%Y %H:%M" }}
              - Organisation: {{ booking.organisation }}
              - Mietzweck: {{ booking.purpose }}
              - Bemerkungen: {{ booking.remarks }}


              Deine Anfrage wird nun bearbeitet. Unser Heimverwalter wird sich in Kürze bei Dir melden.

              [{{booking.links.edit}}]({{booking.links.edit}})

              Freundliche Grüsse

              Verein Pfadiheime St. Georg

              BODY
          ),
          MarkdownTemplate.create!(
            key: :contract_text,
            locale: :'de-CH',
            title: 'Vertrag',
            body: <<~BODY
                # Allgemein
                Der Vermieter überlässt dem Mieter das Pfadiheim "{{ booking.home.name }}" für den nachfolgend aufgeführten Anlass zur alleinigen Benutzung

                # Mietdauer

                - Mietbeginn: {{ booking.occupancy.begins_at | date: "%d.%m.%Y %H:%M" }}
                - Mietende:   {{ booking.occupancy.ends_at | date: "%d.%m.%Y %H:%M" }}

                Die Hausübergabe bzw. –rücknahme erfolgt durch den Heimwart. Der Mieter hat das Haus persönlich zum vereinbarten Zeitpunkt zu übernehmen resp. zu übergeben. Hierfür sind jeweils ca. 30 Minuten einzuplanen. Die Übernahme- und Rückgabezeiten sind unbedingt einzuhalten.

                Verspätungen ab 15 Minuten werden mit CHF 20.- pro angebrochene Viertelstunde verrechnet!

                Der genaue Zeitpunkt der Hausübernahme ist mit dem Heimwart spätestens 5 Tage vor Mietbeginn telefonisch zu vereinbaren:

                *{{ booking.home.janitor }}*

                # Übernahme und Rückgabe

                Die Übernahme- und Rückgabezeiten sind unbedingt einzuhalten. Verspätungen ab 15 Minuten werden mit CHF 20.- pro angebrochene Viertelstunde verrechnet!

                # Zweck der Miete

                *{{ booking.purpose }}*

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
