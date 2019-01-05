require_relative './base_seeder'

module Seeders
  class OrganisationSeeder < BaseSeeder
    def seed_development
      {
        organisations: [
          create(:organisation, name: 'Heimverein St. Georg', ref: ENV.fetch('DEFAULT_ORG', 'st-georg'))
        ]
      }
    end
  end
end
