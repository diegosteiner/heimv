require_relative './base_seeder'

module Seeders
  class TarifSeeder < BaseSeeder
    seed :development do |seeds|
      {
        tarifs: seeds[:homes].map { |home| [home, create_tarifs_for_home(home)] }.to_h
      }
    end

    def create_tarifs_for_home(home)
      [
        Tarifs::Amount.create(home: home, label: 'Lagertarif (unter 16 jährig)', unit: 'Übernachtung', price_per_unit: 13.0, tarif_group: 'Lager/Kurs', invoice_type: :invoice, position: 21),
        Tarifs::Amount.create(home: home, label: 'Lagertarif (über 16 jährig)', unit: 'Übernachtung', price_per_unit: 13.0, tarif_group: 'Lager/Kurs', invoice_type: :invoice, position: 22),
        Tarifs::Amount.create(home: home, label: 'Mindestbelegung', unit: 'pro Nacht', price_per_unit: 200.0, tarif_group: 'Lager/Kurs', invoice_type: :invoice, prefill_usage_method: :nights, position: 23),
        Tarifs::Amount.create(home: home, label: 'Festtarrif', unit: 'pro Tag', price_per_unit: 850.0, tarif_group: 'Privater Anlass / Fest', invoice_type: :invoice, prefill_usage_method: :nights, position: 41),
        Tarifs::Flat.create(home: home, label: 'Reservationsgebühr', price_per_unit: 50.0, tarif_group: 'Reservationsgebühr', invoice_type: :invoice, position: 51),
        Tarifs::Amount.create(home: home, label: 'Kurtaxe (6 bis 16 jährig)', unit: 'Übernachtung', price_per_unit: 0.95, tarif_group: 'Kurtaxe', transient: true, invoice_type: :invoice, position: 31),
        Tarifs::Amount.create(home: home, label: 'Kurtaxe (über 17 jährig)', unit: 'Übernachtung', price_per_unit: 1.9, tarif_group: 'Kurtaxe', transient: true, invoice_type: :invoice, position: 32),
        Tarifs::Metered.create(home: home, label: 'Strom (Hochtarif)', unit: 'kWh', price_per_unit: 0.4, tarif_group: 'Nebenkosten', transient: true, invoice_type: :invoice, meter: 'hochtarif', position: 61),
        Tarifs::Metered.create(home: home, label: 'Strom (Niedertarif)', unit: 'kWh', price_per_unit: 0.35, tarif_group: 'Nebenkosten', transient: true, invoice_type: :invoice, meter: 'niedertarif', position: 62),
        Tarifs::Amount.create(home: home, label: 'Brennholz', unit: 'Harass', price_per_unit: 12.0, tarif_group: 'Nebenkosten', transient: true, invoice_type: :invoice, position: 63),
        Tarifs::Amount.create(home: home, label: 'Abfall', unit: 'pro 60 L Sack', price_per_unit: 2.0, tarif_group: 'Nebenkosten', transient: true, invoice_type: :invoice, position: 64),
        Tarifs::Flat.create(home: home, label: 'Anzahlung (2 Nächte)', price_per_unit: 250.0, tarif_group: 'Anzahlung', invoice_type: :deposit, position: 12),
        Tarifs::Flat.create(home: home, label: 'Anzahlung (3 Nächte)', price_per_unit: 500.0, tarif_group: 'Anzahlung', invoice_type: :deposit, position: 13),
        Tarifs::Flat.create(home: home, label: 'Anzahlung (4 Nächte)', price_per_unit: 750.0, tarif_group: 'Anzahlung', invoice_type: :deposit, position: 14),
        Tarifs::Flat.create(home: home, label: 'Schäden', price_per_unit: 0.0, tarif_group: 'Schäden', invoice_type: :invoice, position: 71),
        Tarifs::Flat.create(home: home, label: 'Anzahlung (1 Nacht)', price_per_unit: 150.0, tarif_group: 'Anzahlung', invoice_type: :deposit, position: 11),
      ].map { |tarif| [tarif.label, tarif] }.to_h
    end
  end
end
