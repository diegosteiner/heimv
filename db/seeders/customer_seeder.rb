require_relative './base_seeder'

module Seeders
  class CustomerSeeder < BaseSeeder
    def seed
      return {} if production?
      {
        customers: create_list(:customer, 10)
      }
    end
  end
end
