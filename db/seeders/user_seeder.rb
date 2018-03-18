require_relative './base_seeder'

module Seeders
  class UserSeeder < BaseSeeder
    def seed_production
      {
        admin: create(:user, :admin, email: 'admin@hv.dev')
      }
    end

    def seed_development
      {
        admin: create(:user, :admin, email: 'admin@hv.dev'),
        users: [create(:user, email: 'user@hv.dev')]
      }
    end
  end
end
