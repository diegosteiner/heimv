# HeimV Handbuch

## Textvorlagen

### Variablen

<pre>
booking:
  agent_booking:
  approximate_headcount: Erwartete Anzahl Personen
  cancellation_reason: Annulierungsgrund
  committed_request: Verbindlichkeit der Mietanfrage
  deadline: Frist
    at: Fris bis Datum / Uhrzeit (muss mit "| datetime_format" kombiniert werden)
    postponable_for: Verlängerbar für n Sekunden
  home: Heim
    address: Adresse des Heims
    janitor: Angaben zum Heimwart
    min_occupation: Mindestbelegung
    name: Name des Heims
  invoice_address: Rechnungsadresse
  links: Links
    edit: Link für den Mieter
    manage: Link für den Vermieter
  occupancy: Belegung
    begins_at: Beginn der Belegung (muss mit "| datetime_format" kombiniert werden)
    ends_at: Ende der Belegung (muss mit "| datetime_format" kombiniert werden)
    home_id: ID des Heims
    occupancy_type: Belegungstyp
    remarks: Bemerkungen des Mieters
  organisation: Organisation
    address: Addresse der Organisation, Sitz
    booking_purposes: Liste aller Mietzwecke der Organisation
    email: E-Mail der Organisation
    esr_beneficiary_account: 01-318421-1
    links: Links
      privacy_statement_pdf: Link zur Datenschutzerklärung
      terms_pdf: Link zu den AGB
    name: Name der Organisation
    notification_footer: Generelle Fusszeile
  purpose: Mietzweck
    key: Schlüssel
    title: Mietzweck
  ref: Referenznummer der Buchung
  remarks: Bemerkungen des Mieters
  tenant: Mieter
    additional_address: Addresszusatz
    city: Ort
    email: E-Mail
    first_name: Vorname
    last_name: Nachname
    nickname: Pfadiname
    salutation_name: Anrede mit Name
    street_address: Addresse
    zipcode: PLZ
  tenant_organisation: Organisation des Mieters
</pre>

Variabeln im Text verwenden:

<pre>
Hallo {{ booking.tenant.first_name }}!
</pre>

Logik im Text verwenden:

<pre>
{% if booking.purpose.key == 'camp' %}
  Wir wünschen euch viel Spass in eurem Lager in unserem Heim!
{% else %}
  Wir wünschen Ihnen einen schönen Aufenthalt in unserem Heim!
{% endif %}
</pre>
