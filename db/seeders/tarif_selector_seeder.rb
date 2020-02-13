require_relative './base_seeder'

module Seeders
  class TarifSelectorSeeder < BaseSeeder
    seed :development do |seeds|
      {
        tarif_selectors: seeds[:tarifs].map do |home, tarifs|
          [
            # TarifSelectors::BookingPurpose.create(home: home).tap do |tarif_selector|
            #   tarif_selector.tarif_tarif_selectors.instance_eval do
            #     create(tarif: tarifs['Lagertarif (unter 16 jährig)'], distinction: 'camp')
            #     create(tarif: tarifs['Lagertarif (über 16 jährig)'], distinction: 'camp')
            #     create(tarif: tarifs['Mindestbelegung'], distinction: 'camp')
            #     create(tarif: tarifs['Kurtaxe (6 bis 16 jährig)'], distinction: 'camp')
            #     create(tarif: tarifs['Kurtaxe (über 17 jährig)'], distinction: 'camp')
            #     create(tarif: tarifs['Festtarrif'], distinction: 'event')
            #   end
            # end,
            # TarifSelectors::AlwaysApply.create(home: home).tap do |tarif_selector|
            #   tarif_selector.tarif_tarif_selectors.instance_eval do
            #     create(tarif: tarifs['Reservationsgebühr'])
            #     create(tarif: tarifs['Strom (Hochtarif)'])
            #     create(tarif: tarifs['Strom (Niedertarif)'])
            #     create(tarif: tarifs['Brennholz'])
            #     create(tarif: tarifs['Abfall'])
            #   end
            # end,
            # TarifSelectors::BookingApproximateHeadcountPerNight.create(home: home).tap do |tarif_selector|
            #   tarif_selector.tarif_tarif_selectors.instance_eval do
            #     # create(tarif: tarifs['Mindestbelegung'], distinction: '<12')
            #     # create(tarif: tarifs['Mindestbelegung'], distinction: '>11')
            #     # create(tarif: tarifs['Lagertarif (unter 16 jährig)'], distinction: '>11')
            #     # create(tarif: tarifs['Lagertarif (über 16 jährig)'], distinction: '>11')
            #   end
            # end,
            # TarifSelectors::BookingNights.create(home: home).tap do |tarif_selector|
            #   tarif_selector.tarif_tarif_selectors.instance_eval do
            #     create(tarif: tarifs['Festtarrif'], veto: false)
            #     create(tarif: tarifs['Kurtaxe (6 bis 16 jährig)'], distinction: '>0')
            #     create(tarif: tarifs['Kurtaxe (über 17 jährig)'], distinction: '>0')
            #     create(tarif: tarifs['Anzahlung (2 Nächte)'], distinction: '=2')
            #     create(tarif: tarifs['Anzahlung (3 Nächte)'], distinction: '=3')
            #     create(tarif: tarifs['Anzahlung (4 Nächte)'], distinction: '>3')
            #     create(tarif: tarifs['Anzahlung (1 Nacht)'], distinction: '<2')
            #   end
            # end
          ]
        end
      }
    end
  end
end
