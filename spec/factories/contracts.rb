FactoryBot.define do
  factory :contract do
    booking
    title 'Mietvertrag'
    text <<~EOTEXT
      ##### Allgemein
      Der Vermieter  überlässt  dem  Mieter  das  Pfadiheim  Birchli  in  Einsiedeln  für  den  nachfolgend  aufgeführten  Anlass  zur  alleinigen  Benutzung
        ##### Mietdauer
      **Mietbeginn**: %<begins_at>s
      **Mietende**: %<ends_at>s
        Die  Hausübergabe  bzw.  –rücknahme  erfolgt  durch  den  Heimwart.  Der  Mieter  hat  das  Haus  persönlich  zum  vereinbarten  Zeitpunkt  zu übernehmen  resp.  zu  übergeben.  Hierfür  sind  jeweils  ca.  30  Minuten  einzuplanen. Die  Übernahme-  und  Rückgabezeiten  sind  unbedingt  einzuhalten.  Verspätungen  ab  15  Minuten  werden  mit  CHF  20.-  pro  angebrochene  Viertelstunde  verrechnet!
        Der  genaue  Zeitpunkt  der  Hausübernahme  ist  mit  dem  Heimwart  spätestens  5  Tage  vor  Mietbeginn  telefonisch  zu  vereinbaren:
        * %<janitor>s
        ##### Übernahme und Rückgabe
      Die  Übernahme-  und  Rückgabezeiten  sind  unbedingt  einzuhalten.  Verspätungen  ab  15  Minuten  werden  mit  CHF  20.-  pro  angebrochene  Viertelstunde  verrechnet!
        ##### Zweck der Miete
      (durch den Mieter auszufüllen)
      _______________________________________________________________________________________
      _______________________________________________________________________________________
        ##### Mietpreis
      Die  Mindestbelegung  beträgt  durchschnittlich  12  Personen  pro  Nacht.

        ##### Anzahlung
      Die  Anzahlung  wird  bei  Abschluss  des  Vertrages  fällig
    EOTEXT

    trait :sent do
      sent_at { 1.week.ago }

      trait :signed do
        signed_at { 3.days.ago }
      end
    end
  end
end
