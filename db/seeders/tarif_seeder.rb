require_relative './base_seeder'

module Seeders
  class TarifSeeder < BaseSeeder
    def seed_development
      {
        tarifs: seeds[:homes].map do |home|
          Tarifs::Amount.create(home: home, label: 'Preis pro Übernachtung', unit: 'Übernachtungen (unter 16 jährig)', price_per_unit: 13.0, tarif_group: 'Lager/Kurs')
          Tarifs::Amount.create(home: home, label: 'Preis pro Übernachtung', unit: 'Übernachtungen (über 16 jährig)', price_per_unit: 13.0, tarif_group: 'Lager/Kurs')
          Tarifs::Amount.create(home: home, label: 'Mindestbelegung', unit: 'pro Nacht', price_per_unit: 200.0, tarif_group: 'Lager/Kurs')
          Tarifs::Amount.create(home: home, label: 'Pauschalpreis', unit: 'pro Tag', price_per_unit: 850.0, tarif_group: 'Privater Anlass / Fest')
          Tarifs::Flat.create(home: home, label: 'Reservationsgebühr', price_per_unit: 50.0, tarif_group: 'Reservationsgebühr')
          Tarifs::Amount.create(home: home, label: 'Kurtaxe pro Übernachtung', unit: 'Übernachtungen (6 bis 16 jährig)', price_per_unit: 0.95, tarif_group: 'Kurtaxe', transient: true)
          Tarifs::Amount.create(home: home, label: 'Kurtaxe pro Übernachtung', unit: 'Übernachtungen (über 17 jährig)', price_per_unit: 1.9, tarif_group: 'Kurtaxe', transient: true)
          Tarifs::Amount.create(home: home, label: 'Strom (Hochtarif)', unit: 'kWh', price_per_unit: 0.4, tarif_group: 'Nebenkosten')
          Tarifs::Amount.create(home: home, label: 'Strom (Niedertarif)', unit: 'kWh', price_per_unit: 0.35, tarif_group: 'Nebenkosten')
          Tarifs::Amount.create(home: home, label: 'Brennholz', unit: 'Harass', price_per_unit: 12.0, tarif_group: 'Nebenkosten')
          Tarifs::Amount.create(home: home, label: 'Abfall', unit: 'pro 60 L Sack', price_per_unit: 2.0, tarif_group: 'Nebenkosten')
          Tarifs::Flat.create(home: home, label: 'Anzahlung (2 Nächte)', price_per_unit: 250.0, tarif_group: 'Anzahlung')
          Tarifs::Flat.create(home: home, label: 'Anzahlung (3 Nächte)', price_per_unit: 500.0, tarif_group: 'Anzahlung')
          Tarifs::Flat.create(home: home, label: 'Anzahlung (4 Nächte)', price_per_unit: 750.0, tarif_group: 'Anzahlung')
          Tarifs::Flat.create(home: home, label: 'Gutschrift Anzahlung (2 Nächte)', price_per_unit: -250.0, tarif_group: 'Anzahlung')
          Tarifs::Flat.create(home: home, label: 'Gutschrift Anzahlung (3 Nächte)', price_per_unit: -500.0, tarif_group: 'Anzahlung')
          Tarifs::Flat.create(home: home, label: 'Gutschrift Anzahlung (4 Nächte)', price_per_unit: -750.0, tarif_group: 'Anzahlung')
        end
      }
    end
  end
end
