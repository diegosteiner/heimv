require_relative './base_seeder'

module Seeders
  class CustomerSeeder < BaseSeeder
    def seed_development
      {
        customers: create_list(:customer, 10)
      }
    end
  end
end
