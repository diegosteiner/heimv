require_relative './base_seeder'

module Seeders
  class HomeSeeder < BaseSeeder
    def seed
      return {} if production?
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
