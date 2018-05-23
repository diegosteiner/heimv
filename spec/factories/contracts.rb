FactoryBot.define do
  factory :contract do
    booking
    title 'Mietvertrag'
    text <<~EOF
      ##### Allgemein
      Der Vermieter  überlässt  dem  Mieter  das  Pfadiheim  Birchli  in  Einsiedeln  für  den  nachfolgend  aufgeführten  Anlass  zur  alleinigen  Benutzung

      ##### Mietdauer
      **Mietbeginn**: %{begins_at}
      **Mietende**: %{ends_at}

      Die  Hausübergabe  bzw.  –rücknahme  erfolgt  durch  den  Heimwart.  Der  Mieter  hat  das  Haus  persönlich  zum  vereinbarten  Zeitpunkt  zu übernehmen  resp.  zu  übergeben.  Hierfür  sind  jeweils  ca.  30  Minuten  einzuplanen. Die  Übernahme-  und  Rückgabezeiten  sind  unbedingt  einzuhalten.  Verspätungen  ab  15  Minuten  werden  mit  CHF  20.-  pro  angebrochene  Viertelstunde  verrechnet!

      Der  genaue  Zeitpunkt  der  Hausübernahme  ist  mit  dem  Heimwart  spätestens  5  Tage  vor  Mietbeginn  telefonisch  zu  vereinbaren:

      * %{janitor}

      ##### Übernahme und Rückgabe
      Die  Übernahme-  und  Rückgabezeiten  sind  unbedingt  einzuhalten.  Verspätungen  ab  15  Minuten  werden  mit  CHF  20.-  pro  angebrochene  Viertelstunde  verrechnet!

      ##### Zweck der Miete
      (durch den Mieter auszufüllen)
      _______________________________________________________________________________________
      _______________________________________________________________________________________

      ##### Mietpreis
      Die  Mindestbelegung  beträgt  durchschnittlich  12  Personen  pro  Nacht.

      1.10  CHFElektrische  Energie:Telefon:Kehrichtgebühren:Brennholz:gemäss  ortsüblichem  Tarif1.512.00  CHFgemäss  ortsüblichem  Tarif480.00Gebühren  x  pro  angebrauchte  Normkiste  (60  x  40  x  30):Die  Anzahlung  wird  bei  Abschluss  des  Vertrages  fällig.  CHFDienstag,  26.  Dezember  2017Samstag,  30.  Dezember  2017Zeit:  16:00Zeit:16:0012.00  CHFPro  Person  und  Nacht  für  Personen  bis  25  Jahre  sowie  Leiterinnen  und  Leiter  von  Jugendgruppen  wie  Pfadi,  Blauring,  Jungwacht,  CVJM  etc.17.00  CHFPro  Person  und  Nacht  für  Erwachsene  über  25  Jahre,  die  nicht  eine  Jugendgruppe  gemäss  obiger  Beschreibung  betreuenVermieterMietervertreten  durch:Rover  Stufe  Padi  Rudolf  BraunYanik  FuchsGehrenholz  6e8055    ZürichB20171226Geeringstr.  448049  ZürichChristian  MorgerTel:    Email:  079  262  25  48info@pfadi-heime.ch60.00  CHF4.Zweck  der  MieteDer  genaue  Zeitpunkt  der  Hausübernahme  ist  mit  dem  Heimwart  spätestens  5  Tage  vor  Mietbeginn  telefonisch  zu  vereinbaren:

      ##### Anzahlung
      Die  Anzahlung  wird  bei  Abschluss  des  Vertrages  fällig
    EOF

    trait :sent do
      sent_at { 1.week.ago }

      trait :signed do
        signed_at { 3.days.ago }
      end
    end
  end
end
