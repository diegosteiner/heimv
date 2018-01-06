require_relative './base_seeder'

module Seeders
  class HomeSeeder < BaseSeeder
    def seed
      return {} if production?
      {
        homes: create_list(:home, 3)
      }
    end
  end
end
