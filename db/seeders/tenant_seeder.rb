require_relative './base_seeder'

module Seeders
  class TenantSeeder < BaseSeeder
    seed :development do |seeds|
      {
        tenants: create_list(:tenant, 10)
      }
    end
  end
end
