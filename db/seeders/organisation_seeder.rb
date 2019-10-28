require_relative './base_seeder'

module Seeders
  class OrganisationSeeder < BaseSeeder
    seed :development do |seeds|
      {
        organisation: Organisation.create(
          name: "Heimverein St. Georg",
          address: "Verein Pfadiheime St. Georg\nHeimverwaltung\n\n8000 Zürich",
          booking_strategy_type: BookingStrategies::Default.to_s,
          invoice_ref_strategy_type: RefStrategies::ESR.to_s,
          payment_information: '',
          account_nr: '01-162-8',
          currency: 'CHF',
          message_footer: <<~EOS
                            Verein Pfadiheime St. Georg
                            Heimverwaltung

                            Christian Morger
                            Geeringstrasse 44
                            8049 Zürich
                            Switzerland

                            [+41 79 262 25 48](tel:+41 79 262 25 48)
                            [www.pfadi-heime.ch](//www.pfadi-heime.ch)
                            [info@pfadi-heime.ch](mailto:info@pfadi-heime.ch)
                          EOS
          )
      }
    end
  end
end
