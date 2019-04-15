require_relative './base_seeder'

module Seeders
  class TenantSeeder < BaseSeeder
    def seed_development
      {
        tenants: create_list(:tenant, 10, organisation: @seeds[:organisations].first)
      }
    end
  end
end
