# rubocop:disable Metrics/ClassLength
class BookingNotificationService
  def initialize(booking)
    @booking = booking
  end

  def confirm_request_notification
    BookingMailer.confirm_request(BookingMailerViewModel.new(@booking, @booking.customer.email))
                 .deliver_now
  end

  def booking_agent_request_notification
    BookingMailer.booking_agent_request(BookingMailerViewModel.new(@booking, @booking.booking_agent.email))
                 .deliver_now
  end

  @raw = <<~RAW_MAILS
    E-Mail: E-Mail-Adresse bestätigen
    Geschäftsfall: Mietanfrage>Benutzer stellt Mietanfrage
    Betreff: Pfadi-heime.ch: Bestätige Deine E-Mail-Adresse
    Hallo
    Du hast soeben auf pfadi-heime.ch eine Mietanfrage begonnen. Bitte klicke auf den
    untenstehenden Link, um Deine E-Mail-Adresse zu bestätigen und um die
    Mietanfrage abzuschliessen.
    Link: www.pfadi-heime.ch/reservationen/mailconfirm.html
     E-Mail: Reservationswunsch entgegengenommen
    Geschäftsfall: Mietanfrage>Benutzer stellt Mietanfrage, Punkt 7
    Betreff: Pfadi-heime.ch: Bestätigung Deiner Mietanfrage
    Hallo Murmel
    Hiermit bestätigen wir Deine Mietanfrage auf pfadi-heime.ch:
    Reservationsdetails:
    Lagerhaus: Birchli, Einsiedeln
    Reservation: 12.3.2018 18:00h bis 14.3.2018 18:00h
    Organisation: Pfadi Laupen
    Mietzweck: Lager/Kurs
    Kontaktperson:
    Christian Kaiser / Murmel
    Stadtturmstrasse 15
    5400 Baden
    079 759 13 12
    murmel@pfadi-laupen.ch
    Bemerkungen: Wir benötigen eine Bewilligung für die Autozufahrt.
    Deine Anfrage wird nun bearbeitet. Unser Heimverwalter wird sich in Kürze bei Dir
    melden.
    Anforderungen für neue Heimverwaltungs-Software Version 3 vom 2.11.2017
    Verein Pfadiheime St. Georg, Zürich Seite 45
    Freundliche Grüsse
    Verein Pfadiheime St. Georg
     E-Mail: Provisorische Reservation bestätigt
    Geschäftsfall: Mietanfrage>Heimverwalter prüft neue Mietanfrage, Punkt 6
    Betreff: Pfadi-heime.ch: Bestätigung Deiner provisorischen Reservation
    Hallo Murmel
    Vielen Dank für Deine Mietanfrage auf pfadi-heime.ch. Wir haben Deine Angaben
    geprüft und nun eine provisorische Reservation erstellt. Diese gilt für 14 Tage,
    danach verfällt sie und das Lagerhaus wird wieder freigegeben. Über den folgenden
    Link kannst Du Deine Reservation verlängern, aufheben oder für definitiv erklären.
    Link: www.pfadi-heime.ch/reservationen/directaccess.html?id=A2VP4RDFGF6
    Reservationsdetails:
    Lagerhaus: Birchli, Einsiedeln
    Reservation: 12.3.2018 18:00h bis 14.3.2018 18:00h
    Organisation: Pfadi Laupen
    Mietzweck: Lager/Kurs
    Bemerkungen: Wir benötigen eine Bewilligung für die Autozufahrt.
    Bei Fragen oder Problemen kannst Du Dich jederzeit an unseren Heimverwalter
    wenden: Christian Morger / Smily, 079 262 25 48, info@pfadi-heime.ch
    Freundliche Grüsse
    Verein Pfadiheime St. Georg
     E-Mail: Reservation abgelehnt
    Geschäftsfall 1: Mietanfrage>Heimverwalter prüft neue Mietanfrage, Punkt 10
    Geschäftsfall 2: Vertragsausstellung>Heimverwalter stellt Mietvertrag aus, Punkt 13
    Geschäftsfall 3: Vertragsausstellung>Heimverwalter stellt Mietvertrag aus, Punkt 14
    <falls Geschäftsfall 1>Betreff: Pfadi-heime.ch: Ablehnung Deiner Mietanfrage</1>
    <falls Geschäftsfall 2>Betreff: Pfadi-heime.ch: Ablehnung Deiner Reservation</2>
    <falls Geschäftsfall 3>Betreff: Pfadi-heime.ch: Ablehnung Deiner Vermittlung</3>
    Hallo Murmel
    <falls Geschäftsfall 1>Vielen Dank für Deine Mietanfrage auf pfadi-heime.ch. Wie
    schon persönlich besprochen, müssen wir Deine Anfrage ablehnen.</1>
    <falls Geschäftsfall 2>Wie schon persönlich besprochen, müssen wir Deine Anfrage
    ablehnen.</2>
    <falls Geschäftsfall 3>Wie schon persönlich besprochen, müssen wir die von Dir
    vermittelte Reservation ablehnen.</3>
    Anforderungen für neue Heimverwaltungs-Software Version 3 vom 2.11.2017
    Verein Pfadiheime St. Georg, Zürich Seite 46
    Ablehnungsgrund: Politische Veranstaltungen sind nicht erlaubt.
    Reservationsdetails:
    Lagerhaus: Birchli, Einsiedeln
    Reservation: 12.3.2018 18:00h bis 14.3.2018 18:00h
    Organisation: Pfadi Laupen
    Mietzweck: Lager/Kurs
    Bemerkungen: Wir benötigen eine Bewilligung für die Autozufahrt.
    Freundliche Grüsse
    Verein Pfadiheime St. Georg
     E-Mail: Definitive Reservation bestätigt
    Geschäftsfall 1: Mietanfrage>Heimverwalter prüft neue Mietanfrage, Punkt 13
    Geschäftsfall 2: Mietanfrage>Benutzer erklärt Mietanfrage als definitiv, Punkt 7
    Betreff: Pfadi-heime.ch: Bestätigung Deiner definitiven Reservation
    Hallo Murmel
    <falls Geschäftsfall 1>Vielen Dank für Deine Mietanfrage auf pfadi-heime.ch. Wir
    haben Deine Angaben geprüft und nun eine definitive Reservation erstellt. Unser
    Heimverwalter wird Dir in den nächsten Tagen den Mietvertrag zustellen. </1>
    <falls Geschäftsfall 2>Deine Reservation auf pfadi-heime.ch ist nun definitiv. Unser
    Heimverwalter wird Dir in den nächsten Tagen den Mietvertrag zustellen.</2>
    Reservationsdetails:
    Lagerhaus: Birchli, Einsiedeln
    Reservation: 12.3.2018 18:00h bis 14.3.2018 18:00h
    Organisation: Pfadi Laupen
    Mietzweck: Lager/Kurs
    Bei Fragen oder Problemen kannst Du Dich jederzeit an unseren Heimverwalter
    wenden: Christian Morger / Smily, 079 262 25 48, info@pfadi-heime.ch
    Freundliche Grüsse
    Verein Pfadiheime St. Georg
     E-Mail: Definitive Vermittlung bestätigt
    Geschäftsfall 1: Mietanfrage>Heimverwalter prüft neue Mietanfrage, Punkt 14
    Geschäftsfall 2: Mietanfrage>Benutzer erklärt Mietanfrage als definitiv, Punkt 8
    Betreff: Pfadi-heime.ch: Bestätigung Deiner Vermittlung
    Hallo <Name des Vermittlers>
    <falls Geschäftsfall 1>Vielen Dank für Deine Vermittlung auf pfadi-heime.ch. Wir
    Anforderungen für neue Heimverwaltungs-Software Version 3 vom 2.11.2017
    Verein Pfadiheime St. Georg, Zürich Seite 47
    haben die Angaben des Mieters geprüft und nun eine definitive Reservation erstellt.
    Unser Heimverwalter wird ihm in den nächsten Tagen den Mietvertrag zustellen. </1>
    <falls Geschäftsfall 2>Die Reservation zu Deiner Vermittlung auf pfadi-heime.ch ist
    nun definitiv. Unser Heimverwalter wird dem Mieter in den nächsten Tagen den
    Mietvertrag zustellen.</2>
    Reservationsdetails:
    Lagerhaus: Birchli, Einsiedeln
    Reservation: 12.3.2018 18:00h bis 14.3.2018 18:00h
    Organisation: Pfadi Laupen
    Mietzweck: Lager/Kurs
    Kontaktperson:
    Christian Kaiser / Murmel
    Stadtturmstrasse 15
    5400 Baden
    079 759 13 12
    murmel@pfadi-laupen.ch
    Bemerkungen: Referenz Gruppenhaus: GH255-2018-11-24
    Bei Fragen oder Problemen kannst Du Dich jederzeit an unseren Heimverwalter
    wenden: Christian Morger / Smily, 079 262 25 48, info@pfadi-heime.ch
    Freundliche Grüsse
    Verein Pfadiheime St. Georg
     E-Mail: Provisorische Reservation überfällig
    Geschäftsfall: Mietanfrage>System prüft provisorische Mietanfrage, Punkt 3
    Betreff: Pfadi-heime.ch: Deine Reservation läuft ab
    Hallo Murmel
    Du hast kürzlich auf pfadi-heime.ch eine provisorische Reservation erstellt. Eine
    Reservation gilt für 14 Tage. Wenn sie in dieser Zeit nicht verlängert wird, verfällt sie
    und das Lagerhaus wird wieder freigegeben. Wir geben Dir nochmals 3 Tage Zeit,
    um Deine Reservation zu verlängern oder um sie definitiv zu machen. Klicke dazu auf
    den untenstehenden Link.
    Link: www.pfadi-heime.ch/reservationen/directaccess.html?id=A2VP4RDFGF6
    Reservationsdetails:
    Lagerhaus: Birchli, Einsiedeln
    Reservation: 12.3.2018 18:00h bis 14.3.2018 18:00h
    Organisation: Pfadi Laupen
    Mietzweck: Lager/Kurs
    Kontaktperson:
    Christian Kaiser / Murmel
    Stadtturmstrasse 15
    Anforderungen für neue Heimverwaltungs-Software Version 3 vom 2.11.2017
    Verein Pfadiheime St. Georg, Zürich Seite 48
    5400 Baden
    079 759 13 12
    murmel@pfadi-laupen.ch
    Bemerkungen: Referenz Gruppenhaus: GH255-2018-11-24
    Bei Fragen oder Problemen kannst Du Dich jederzeit an unseren Heimverwalter
    wenden: Christian Morger / Smily, 079 262 25 48, info@pfadi-heime.ch
    Freundliche Grüsse
    Verein Pfadiheime St. Georg
     E-Mail: Provisorische Reservation abgelaufen und annulliert
    Geschäftsfall 1: Mietanfrage>System prüft überfällige Mietanfrage, Punkt 4
    Geschäftsfall 2: Mietanfrage>Benutzer zieht seine Mietanfrage zurück, Punkt 5
    <falls Geschäftsfall 1>Betreff: Pfadi-heime.ch: Deine Reservation ist abgelaufen</1>
    <falls Geschäftsfall 2>Betreff: Pfadi-heime.ch: Deine Reservation wurde
    aufgehoben</2>
    Hallo Murmel
    <falls Geschäftsfall 1>Du hast vor einiger Zeit auf pfadi-heime.ch eine provisorische
    Reservation erstellt. Eine Reservation gilt für 14 Tage und muss danach verlängert
    werden. Weil Du sie nicht rechtzeitig verlängert hast, ist Deine Reservation nun
    verfallen und gelöscht worden. Wir haben das Lagerhaus wieder freigegeben.</1>
    <falls Geschäftsfall 2>Deine Reservation auf pfadi-heime.ch wurde aufgehoben und
    wir haben das Lagerhaus wieder freigegeben.</2>
    Reservationsdetails:
    Lagerhaus: Birchli, Einsiedeln
    Reservation: 12.3.2018 18:00h bis 14.3.2018 18:00h
    Organisation: Pfadi Laupen
    Mietzweck: Lager/Kurs
    Bemerkungen: Referenz Gruppenhaus: GH255-2018-11-24
    Du kannst auf unserem Reservationssystem jederzeit eine neue Reservation erstellen:
    www.pfadi-heime.ch
    Bei Fragen oder Problemen kannst Du Dich jederzeit an unseren Heimverwalter
    wenden: Christian Morger / Smily, 079 262 25 48, info@pfadi-heime.ch
    Freundliche Grüsse
    Verein Pfadiheime St. Georg
     E-Mail: Reservationsbestätigung und Mietvertrag
    Geschäftsfall: Vertragsausstellung>Heimverwalter stellt Mietvertrag aus, Punkt 7
    Geschäftsfall: Vertragsausstellung>Heimverwalter modifiziert Reservation, Punkt 3
    Anforderungen für neue Heimverwaltungs-Software Version 3 vom 2.11.2017
    Verein Pfadiheime St. Georg, Zürich Seite 49
    Betreff: Pfadi-heime.ch: Mietvertrag für Dein Lagerhaus
    Hallo Murmel
    Mit dieser Nachricht erhältst Du die Unterlagen für Deine Lagerhaus-Reservation.
    Bitte lies die Dokumente durch und prüfe, ob alle Daten korrekt sind. Unterschreibe
    dann den Mietvertrag und sende ihn an uns zurück. Falls im Vertrag eine Anzahlung
    vereinbart wurde, ist diese sofort fällig. Bitte beachte, dass der Vertrag erst zustande
    kommt, wenn Anzahlung und unterzeichnetes Vertragsdoppel bei uns angekommen
    sind.
    Reservationsdetails:
    Lagerhaus: Birchli, Einsiedeln
    Reservation: 12.3.2018 18:00h bis 14.3.2018 18:00h
    Organisation: Pfadi Laupen
    Mietzweck: Lager/Kurs
    Zahlungsdetails für Anzahlung:
    Empfänger: Verein Pfadiheime St. Georg, Zürich
    Konto: XXXXXX
    ESR-Referenznummer: 00 00000 00000 00000 00000 00000
    Bei Fragen oder Problemen kannst Du Dich jederzeit an unseren Heimverwalter
    wenden: Christian Morger / Smily, 079 262 25 48, info@pfadi-heime.ch
    Freundliche Grüsse
    Verein Pfadiheime St. Georg
    Attachment: Mietvertrag.pdf, Hausordnung.pdf, evtl. mehr
     E-Mail: Anzahlung/Vertragsdoppel eingegangen
    Geschäftsfall 1: Vertragsausstellung>Benutzer bestätigt Anzahlung, Punkt 5
    Geschäftsfall 2: Vertragsausstellung>Benutzer bestätigt Anzahlung, Punkt 8
    Geschäftsfall 3: Vertragsausstellung>Heimverwalter erhält Vertrag zurück, Punkt 4
    Geschäftsfall 4: Vertragsausstellung>Heimverwalter erhält Vertrag zurück, Punkt 6
    <falls Geschäftsfall 1 oder 2>Betreff: Pfadi-heime.ch: Anzahlung erhalten</1-2>
    <falls Geschäftsfall 3 oder 4>Betreff: Pfadi-heime.ch: Vertragsdoppel erhalten</3-4>
    Hallo Murmel
    <falls Geschäftsfall 1>Soeben haben wir Deine Anzahlung erhalten. Damit steht
    deinem Anlass nichts mehr im Weg. Wir wünschen Dir und Deiner Gruppe einen
    schönen Aufenthalt in unserem Lagerhaus.</1>
    <falls Geschäftsfall 2>Soeben haben wir Deine Anzahlung erhalten, vielen Dank. Bitte
    sende uns auch möglichst rasch das unterzeichnete Vertragsdoppel zurück.</2>
    <falls Geschäftsfall 3>Soeben haben wir das von Dir unterzeichnete Vertragsdoppel
    erhalten. Damit steht deinem Anlass nichts mehr im Weg. Wir wünschen Dir und
    Deiner Gruppe einen schönen Aufenthalt in unserem Lagerhaus.</3>
    Anforderungen für neue Heimverwaltungs-Software Version 3 vom 2.11.2017
    Verein Pfadiheime St. Georg, Zürich Seite 50
    <falls Geschäftsfall 4>Soeben haben wir das von Dir unterzeichnete Vertragsdoppel
    erhalten, vielen Dank. Bitte zahle auch möglichst rasch noch die Anzahlung ein.</4>
    Reservationsdetails:
    Lagerhaus: Birchli, Einsiedeln
    Reservation: 12.3.2018 18:00h bis 14.3.2018 18:00h
    Organisation: Pfadi Laupen
    Mietzweck: Lager/Kurs
    <falls Geschäftsfall 1 oder 3>Heimübergabe:
    Übergabetermin: 12.3.2018 18:00h
    Heimwart: Herr Franz Meier, 079 815 20 92</1-3>
    <falls Geschäftsfall 4>Zahlungsdetails für Anzahlung:
    Empfänger: Verein Pfadiheime St. Georg, Zürich
    Konto: XXXXXX
    ESR-Referenznummer: 00 00000 00000 00000 00000 00000</4>
    Bei Fragen oder Problemen kannst Du Dich jederzeit an unseren Heimverwalter
    wenden: Christian Morger / Smily, 079 262 25 48, info@pfadi-heime.ch
    Freundliche Grüsse
    Verein Pfadiheime St. Georg
     E-Mail: Anzahlung und/oder Vertragsdoppel noch ausstehend
    Geschäftsfall: Vertragsausstellung>System prüft bestätigte Reservation, Punkt 3
    Geschäftsfall: Vertragsausstellung>Heimverwalter moniert Vertragserfüllung, Punkt 6
    Betreff: Pfadi-heime.ch: Anzahlung/Vertrag für Dein Lagerhaus
    Hallo Murmel
    Vor einiger Zeit hast Du die Unterlagen für Deine Lagerhaus-Reservation erhalten.
    Dabei haben wir Dich auch gebeten, ein unterzeichnetes Doppel vom Mietvertrag an
    uns zurückzuschicken<falls Anzahlung> und eine Anzahlung zu leisten</>.
    <falls sowohl Anzahlung als auch Vertragsdoppel fehlt>Bis heute haben wir beides
    noch nicht erhalten. Bitte beachte, dass der Vertrag erst zustande kommt, wenn
    Anzahlung und Vertragsdoppel bei uns angekommen sind. Wir bitten Dich deshalb,
    diese Pendenzen umgehend zu erledigen.</>
    <falls Vertragsdoppel fehlt>Die Anzahlung haben wir erhalten, aber das
    Vertragsdoppel noch nicht. Bitte beachte, dass der Vertrag erst zustande kommt,
    wenn dieses Dokument bei uns angekommen ist. Wir bitten Dich deshalb, diese
    Pendenz umgehend zu erledigen.</>
    <falls Vertragsdoppel fehlt, aber keine Anzahlung gefordert war>Das Vertragsdoppel
    haben wir aber noch nicht erhalten. Bitte beachte, dass der Vertrag erst zustande
    kommt, wenn dieses Dokument bei uns angekommen ist. Wir bitten Dich deshalb,
    diese Pendenz umgehend zu erledigen.</>
    <falls Anzahlung fehlt>Das Vertragsdoppel haben wir erhalten, aber die Anzahlung
    noch nicht. Bitte beachte, dass der Vertrag erst zustande kommt, wenn diese Zahlung
    bei uns angekommen ist. Wir bitten Dich deshalb, diese Pendenz umgehend zu
    Anforderungen für neue Heimverwaltungs-Software Version 3 vom 2.11.2017
    Verein Pfadiheime St. Georg, Zürich Seite 51
    erledigen.</>
    Reservationsdetails:
    Lagerhaus: Birchli, Einsiedeln
    Reservation: 12.3.2018 18:00h bis 14.3.2018 18:00h
    Organisation: Pfadi Laupen
    Mietzweck: Lager/Kurs
    <falls Anzahlung fehlt>Zahlungsdetails für Anzahlung:
    Empfänger: Verein Pfadiheime St. Georg, Zürich
    Konto: XXXXXX
    ESR-Referenznummer: 00 00000 00000 00000 00000 00000</>
    Bei Fragen oder Problemen kannst Du Dich jederzeit an unseren Heimverwalter
    wenden: Christian Morger / Smily, 079 262 25 48, info@pfadi-heime.ch
    Freundliche Grüsse
    Verein Pfadiheime St. Georg
     E-Mail: Bestätigte/überfällige Reservation abgelaufen und annulliert
    Geschäftsfall 1: Vertragsausstellung>Mieter tritt vom Vertrag zurück, Punkt 5
    Geschäftsfall 2: Vertragsausstellung>Mieter tritt vom Vertrag zurück, Punkt 6
    Geschäftsfall 3: Vertragsausstellung>Heimverwalter moniert Vertragserfüllung, Punkt 10
    Geschäftsfall 4: Vertragsausstellung>Heimverwalter moniert Vertragserfüllung, Punkt 11
    Betreff: Pfadi-heime.ch: Vertragsauflösung/Annullation Deiner Reservation
    Hallo Murmel
    <falls Geschäftsfall 1 oder 3>Wie schon persönlich besprochen, ist der Vertrag für
    untenstehende Reservation nicht zustande gekommen und wir haben sie deshalb
    annulliert.</1-3>
    <falls Geschäftsfall 2 oder 4>Die von Dir vermittelte Reservation ist nicht zustande
    gekommen, wir haben sie deshalb annulliert.</2-4>
    Annullationsgrund: Anzahlung nicht geleistet, Mieter nicht erreicht.
    Reservationsdetails:
    Lagerhaus: Birchli, Einsiedeln
    Reservation: 12.3.2018 18:00h bis 14.3.2018 18:00h
    Organisation: Pfadi Laupen
    Mietzweck: Lager/Kurs
    Bemerkungen: Referenz Gruppenhaus: GH255-2018-11-24
    Du kannst auf unserem Reservationssystem jederzeit eine neue Reservation erstellen:
    www.pfadi-heime.ch
    Bei Fragen oder Problemen kannst Du Dich jederzeit an unseren Heimverwalter
    wenden: Christian Morger / Smily, 079 262 25 48, info@pfadi-heime.ch
    Anforderungen für neue Heimverwaltungs-Software Version 3 vom 2.11.2017
    Verein Pfadiheime St. Georg, Zürich Seite 52
    Freundliche Grüsse
    Verein Pfadiheime St. Georg
     E-Mail: Rechnung
    Geschäftsfall: Abrechnung>Heimverwalter erstellt und verschickt Rechnung, Punkt 6
    Betreff: Pfadi-heime.ch: Rechnung für Dein Lagerhaus
    Hallo Murmel
    Mit dieser Nachricht erhältst Du die Rechnung für Deine Lagerhaus-Reservation. Bitte
    bezahle diese innert der Zahlungsfrist von 30 Tagen.
    Reservationsdetails:
    Lagerhaus: Birchli, Einsiedeln
    Reservation: 12.3.2018 18:00h bis 14.3.2018 18:00h
    Organisation: Pfadi Laupen
    Mietzweck: Lager/Kurs
    Zahlungsdetails:
    Empfänger: Verein Pfadiheime St. Georg, Zürich
    Konto: XXXXXX
    ESR-Referenznummer: 00 00000 00000 00000 00000 00000
    Bei Fragen oder Problemen kannst Du Dich jederzeit an unseren Heimverwalter
    wenden: Christian Morger / Smily, 079 262 25 48, info@pfadi-heime.ch
    Freundliche Grüsse
    Verein Pfadiheime St. Georg
     E-Mail: Zahlungseingang
    Geschäftsfall: Abrechnung>Benutzer bestätigt Zahlungseingang, Punkt 6
    Betreff: Pfadi-heime.ch: Vielen Dank für Deine Zahlung
    Hallo Murmel
    Soeben haben wir Deine Zahlung für die Lagerhaus-Reservation erhalten, vielen
    Dank. Damit ist nun alles erledigt. Wir bedanken uns für den Besuch und würden uns
    freuen, Dich und Deine Gruppe ein anderes Mal wieder bei uns zu beherbergen.
    Ach ja, etwas noch: Uns interessiert es, wie gut es Euch bei uns gefallen hat. Sicher
    hast Du noch ein paar Minuten Zeit, um uns ein Feedback zu geben. Hier geht’s zu
    unserer Kundenzufriedenheitsumfrage:
    www.surveymonkey.com/pfadi-heime-ch/survey.asp
    Reservationsdetails:
    Lagerhaus: Birchli, Einsiedeln
    Reservation: 12.3.2018 18:00h bis 14.3.2018 18:00h
    Anforderungen für neue Heimverwaltungs-Software Version 3 vom 2.11.2017
    Verein Pfadiheime St. Georg, Zürich Seite 53
    Organisation: Pfadi Laupen
    Mietzweck: Lager/Kurs
    Freundliche Grüsse
    Verein Pfadiheime St. Georg
     E-Mail: Zahlungserinnerung
    Geschäftsfall: Abrechnung>System prüft Zahlungsausstände, Punkt 3
    Geschäftsfall: Abrechnung>Heimverwalter moniert ausstehende Zahlungen, Punkt 5
    Betreff: Pfadi-heime.ch: Zahlungserinnerung für Deine Lagerhaus-Rechnung
    Hallo Murmel
    Vor einiger Zeit haben wir Dir die Rechnung für Deine Lagerhaus-Reservation
    geschickt. Die Zahlungsfrist von 30 Tagen ist nun abgelaufen, doch wir haben noch
    keine Zahlung von Dir erhalten. Bitte bezahle die überfällige Rechnung in den
    nächsten Tagen.
    Reservationsdetails:
    Lagerhaus: Birchli, Einsiedeln
    Reservation: 12.3.2018 18:00h bis 14.3.2018 18:00h
    Organisation: Pfadi Laupen
    Mietzweck: Lager/Kurs
    Zahlungsdetails:
    Empfänger: Verein Pfadiheime St. Georg, Zürich
    Konto: XXXXXX
    ESR-Referenznummer: 00 00000 00000 00000 00000 00000
    Bei Fragen oder Problemen kannst Du Dich jederzeit an unseren Heimverwalter
    wenden: Christian Morger / Smily, 079 262 25 48, info@pfadi-heime.ch
    Freundliche Grüsse
    Verein Pfadiheime St. Georg
RAW_MAILS
end
# rubocop:enable Metrics/ClassLength
