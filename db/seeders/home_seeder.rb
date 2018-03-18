require_relative './base_seeder'

module Seeders
  class HomeSeeder < BaseSeeder
    def seed_development
      {
        homes: [
          create(:home, name: 'Birchli', ref: 'bir'),
          create(:home, name: 'Mühlebächli', ref: 'muehli'),
          create(:home, name: 'Villa Kunterbunt', ref: 'villa')
        ]
      }
    end
  end
end
