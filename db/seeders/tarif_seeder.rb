require_relative './base_seeder'

module Seeders
  class TarifSeeder < BaseSeeder
    def seed_development
      {
        tarifs: seeds[:homes].map do |home|
          Tarif::Amount.create(home: home, label: 'Preis pro Übernachtung', unit: 'Übernachtungen (unter 16 jährig)', price_per_unit: 13.0)
          Tarif::Amount.create(home: home, label: 'Preis pro Übernachtung', unit: 'Übernachtungen (über 16 jährig)', price_per_unit: 13.0)
          Tarif::Amount.create(home: home, label: 'Mindestbelegung', unit: 'pro Nacht', price_per_unit: 200.0)
        end
      }
    end
  end
end
